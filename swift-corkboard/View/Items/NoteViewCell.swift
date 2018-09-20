//
//  NoteViewCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/16/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import PusherSwift
import Alamofire

class NoteViewCell: UICollectionViewCell {
    
    @IBOutlet weak var content: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.content.delegate = self
        content.isUserInteractionEnabled = true
        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAwayFunction(_:))))
        
        var frameRect : CGRect = self.content.frame;
        frameRect.size.height = 100;
        content.frame = frameRect;
        listenForChanges()
    }
    
    var pusher : Pusher!
    var randomUuid : String = ""
    var noteId : Any = ""

    @objc func tappedAwayFunction(_ sender: UITapGestureRecognizer) {
        print("tapped away")
        print(self.noteId)
        self.content.resignFirstResponder()
    }
    
    func sendToPusher(text: String) {
        let params : [String : Any] = ["text": text, "from": self.randomUuid]
        let url = "http://localhost:5000/update_text"
        Alamofire.request(url, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
    }

    func listenForChanges() {
        pusher = Pusher(key: "68d00ab5cb679315179f", options: PusherClientOptions(
            host: .cluster("us2")
        ))
        let channel = pusher.subscribe("Corkboard")
        let _ = channel.bind(eventName: "text_update", callback: { (data: Any?) -> Void in
            if let data = data as? [String: AnyObject] {
                let fromDeviceId = data["deviceId"] as! String
                if fromDeviceId != self.randomUuid {
                    let text = data["text"] as! String
                    self.content.text = text
                }
            }
        })
        pusher.connect()
    }

}

extension NoteViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("entered text")
        sendToPusher(text: content.text!)

    }
}
    

