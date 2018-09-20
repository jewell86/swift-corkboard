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

class NoteViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var content: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        content.delegate = self
        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAwayFunction(_:))))
        var frameRect : CGRect = self.content.frame;
        frameRect.size.height = 100; //
        content.frame = frameRect;
        listenForChanges()
        content.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    var pusher : Pusher!
    var randomUuid : String = ""
    var noteId : Any = ""

    @objc func textFieldDidChange(_ textView: UITextView) {
//        if content.text!.count > 0 {
            print("TEXT CHANGING!!")
            sendToPusher(text: content.text!)
    }
    
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
        pusher = Pusher(key: "PUSHER_KEY", options: PusherClientOptions(
            host: .cluster("PUSHER_CLUSTER")
        ))
        let channel = pusher.subscribe("collabo")
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
