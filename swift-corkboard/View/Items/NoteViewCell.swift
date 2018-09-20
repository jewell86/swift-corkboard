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
import SVProgressHUD

class NoteViewCell: UICollectionViewCell {
    
    @IBOutlet weak var content: UITextView!
    
    let defaults = UserDefaults.standard

    override func awakeFromNib() {

        super.awakeFromNib()
        self.content.delegate = self
        content.isUserInteractionEnabled = true
        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedAwayFunction(_:))))
        content.isScrollEnabled = true
        var frameRect : CGRect = self.content.frame;
        frameRect.size.height = 100;
        content.frame = frameRect;
        listenForChanges()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    var pusher : Pusher!
    var randomUuid : String = ""
    var noteId : String = ""
    
    @IBAction func saveNote(_ sender: UIButton) {
        print("BUTTON PUSHED!")
        saveNoteRequest()
    }
    
    func saveNoteRequest() {
//        let params : [String : Any] = ["content": self.content.text! as NSString, "id": self.noteId as! NSInteger]
        print("CONTENT TEXT:")
        print(type(of: self.content.text!))
        print(self.content.text!)
        
        print("ID")
        print(type(of: self.noteId))
        print(self.noteId)
        let id = self.noteId
        let url = "http://localhost:5000/updateItem"
        Alamofire.request(url, method: .patch, parameters: ["content": self.content.text!, "id": id], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
        print("hello")
    }

    @objc func tappedAwayFunction(_ sender: UITapGestureRecognizer) {
        print("tapped away")
        print(self.noteId)
        self.content.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.content.frame.origin.y == 1.0 {
//                self.content.frame.origin.y -= keyboardSize.height
//            }
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.frame.origin.y != 1.0 {
//                self.content.frame.origin.y += keyboardSize.height
//            }
//        }
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("done editing!")
    }
}
    

