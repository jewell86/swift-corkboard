//
//  BoardSettingsViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/11/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BoardSettingsViewController: UIViewController, UINavigationControllerDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        listAllUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    let defaults = UserDefaults.standard


    //ADD USER TO BOARD
    @IBOutlet var addUserTextField: UITextField!
    @IBAction func addUserButton(_ sender: UIButton) {
        let boardId = defaults.string(forKey: "boardId")
        let username = addUserTextField.text
        let params : [String : Any] = ["username": username]
        let url = "http://localhost:5000/\(boardId!)/addUser"
        let newUrl = "http://localhost:5000/byUsername/\(username!)"
        Alamofire.request(newUrl, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let user = data["response"]
                let userId = user["id"]
                Alamofire.request(url, method: .post, parameters: ["id" : userId]).responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Succeeded")
                        let alert = UIAlertController(title: "Success!", message: "\(String(describing: username!)) added!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.viewDidLoad()
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "Ut oh!", message: "\(String(describing: username!)) could not be added!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            self.addUserTextField.text = ""
            self.viewDidLoad()
        }

    }
    
    //REMOVE USER FROM BOARD
    @IBOutlet var removeUserInput: UITextField!
    @IBAction func removeUserButton(_ sender: UIButton) {
        let boardId = defaults.string(forKey: "boardId")
        let username = removeUserInput.text
        let params : [String : Any] = ["username": username]
        let newUrl = "http://localhost:5000/byUsername/\(username!)"
        Alamofire.request(newUrl, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let user = data["response"]
                let userId = user["id"]
                let url = "http://localhost:5000/\(boardId!)/\(userId)/removeUser"
//                let params : [String : Any] = ["id": userId]
                Alamofire.request(url, method: .delete).responseJSON { response in
                    switch response.result {
                    case .success:
                        print("Succeeded")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            self.removeUserInput.text = ""
            self.viewDidLoad()
        }

    }
    
    //RENAME BOARD
    @IBOutlet var renameBoardInput: UITextField!
    @IBAction func renameBoardButton(_ sender: UIButton) {
        let boardId = defaults.string(forKey: "boardId")
        let newName = renameBoardInput.text!
        let url = "http://localhost:5000/\(boardId!)/renameBoard"
        let params : [String : Any] = ["title" : newName]
        Alamofire.request(url, method: .patch, parameters: params).responseJSON { response in
            print(response)
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
            self.defaults.set("\(self.renameBoardInput.text!)", forKey: "title")
            self.renameBoardInput.text = ""
        }

    }
    
    //ALL BOARD-USERS LIST
    @IBOutlet var allUsersLabel: UILabel!
    func listAllUsers() {
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let params : [String : Any] = ["boards_id": boardId]
        let url = "http://localhost:5000/\(boardId!)/getAllUsers"
        Alamofire.request(url, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let allUsers = data["response"]
                self.allUsersLabel.text = ""
                for user in allUsers.arrayValue {
                    if user["users_id"].stringValue != userId {
                        let newUrl = "http://localhost:5000/byId/\(user["users_id"].intValue)"
                        Alamofire.request(newUrl, method: .get).responseJSON { response in
                            if let data : JSON = JSON(response.result.value) {
                                let user = data["response"]
                                let username = user["username"]
                                self.allUsersLabel.text = self.allUsersLabel.text!+"\n\(username.stringValue)"
                            }
                        }
                    }
                }
            }
    }
    }
        
    
        //CODE TO EXTRACT OUT ALL USERS_ID MINUS THIS USER, LOOP THRU ALL & PRINT
        
    
    //DELETE BOARD
    @IBAction func deleteBoardButton(_ sender: UIButton) {
        //ALERT _ ARE YOU SURE?
        //IF YES:
        let boardId = defaults.string(forKey: "boardId")
        let url = "http://localhost:5000/\(boardId!)/deleteBoard"
        Alamofire.request(url, method: .delete).responseJSON { response in
            switch response.result {
            case .success:
                print("Succeeded")
            case .failure(let error):
                print(error)
            }
        }
        //GO TO MAIN VC
        
        //IF NO: ALERT DISMISS
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
