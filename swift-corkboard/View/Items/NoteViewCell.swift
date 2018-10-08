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

class NoteViewCell: UICollectionViewCell, UITextViewDelegate {
    static let API_ENDPOINT = "https://powerful-earth-36700.herokuapp.com"
    
    @IBOutlet var content: UITextView!
    @IBOutlet var userPhoto: UIImageView!
    
    let defaults = UserDefaults.standard
    var pusher : Pusher!
    var chillPill = true
    var randomUuid : String = ""
    var noteId : String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        self.content.delegate = self
        self.randomUuid = NSUUID().uuidString
        content.isUserInteractionEnabled = true
        listenForChanges()
    }
    
    @IBAction func saveNote(_ sender: UIButton) {
        let id = self.noteId
        print("noteId")
        print(id)
        let url = "https://powerful-earth-36700.herokuapp.com/updateItem/"
        Alamofire.request(url, method: .patch, parameters: ["content": self.content.text!, "id": id], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func sendToPusher(text: String) {
        let params : Parameters = ["text": text, "from": self.randomUuid]
        let url = "https://powerful-earth-36700.herokuapp.com/update_text"
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

    func textViewDidChange(_ textView: UITextView) {
        print("entered text")
        sendToPusher(text: content.text!)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("done editing!")
    }
}
    

