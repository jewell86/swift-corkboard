//
//  ListCell.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/17/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import PusherSwift
import Alamofire
//SAVE BUTTON
//MAKE LIST TITLE A LABEL
class ListCell: UICollectionViewCell, UITextViewDelegate {
    static let API_ENDPOINT = "http://localhost:5000"

    @IBOutlet var listItemsTable: [UITableView]!

    @IBOutlet var listTitle: UILabel!


    let defaults = UserDefaults.standard


    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedAwayFunction(_:))))
    }

    var pusher : Pusher!
    var chillPill = true
    var randomUuid : String = ""
    var listId : String = ""


    @IBAction func saveList(_ sender: UIButton) {
        let id = self.listId
        let url = "http://localhost:5000/updateItem"
//        let params = ["content": self.listItems.text!, "id": id]
//        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
//            switch response.result {
//            case .success:
//                print("Succeeded")
//            case .failure(let error):
//                print(error)
//            }
//        }
    }

    @objc func tappedAwayFunction(_ sender: UITapGestureRecognizer) {
        print("tapped away")
        print(self.listId)
//        self.listItems.resignFirstResponder()
    }
    
    func sendToPusher(text: String) {
        let params : Parameters = ["text": text, "from": self.randomUuid]
        let url = "http://localhost:5000/update_text"
        Alamofire.request(NoteViewCell.API_ENDPOINT + "/update_text", method: .post, parameters: params).validate().responseJSON { response in
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
//                    self.listItems.text = text
                }
            }
        })
        pusher.connect()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("entered text")
//        sendToPusher(text: listItems.text!)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("done editing!")
    }
}
