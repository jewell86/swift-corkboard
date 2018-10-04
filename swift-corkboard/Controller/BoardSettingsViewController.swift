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
import FirebaseFirestore
import Firebase
import FirebaseStorage
import FirebaseUI

class BoardSettingsViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet var tableView: UITableView!
    let defaults = UserDefaults.standard
    var userNameArray : [String] = [String]()
    var userPhotoArray : [String] = [String]()
    var userIdArray : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameArray = [String]()
        userPhotoArray = [String]()
        userIdArray = [String]()
        tableView.delegate = self
        tableView.dataSource = self
        listAllUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("IN THE CELLS")
        print(userNameArray.count)
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        print(userNameArray[indexPath.row])
        print(cell)
        cell.userName.text = userNameArray[indexPath.row]
        cell.usersId = userIdArray[indexPath.row]
        let id = userIdArray[indexPath.row]
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/users/\(id).jpg")
        cell.userPhoto?.sd_setImage(with: imageRef)
        cell.userPhoto?.layer.masksToBounds = false
        cell.userPhoto?.layer.cornerRadius = (cell.userPhoto?.frame.height)!/2
        cell.userPhoto?.clipsToBounds = true
        return cell
    }
    

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
//    @IBOutlet var allUsersLabel: UILabel!
    
    
    func listAllUsers() {
        userNameArray = [String]()
        userPhotoArray = [String]()
        userIdArray = [String]()
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        var thisUser : String = ""
        let params : [String : Any] = ["boards_id": boardId]
        let url = "http://localhost:5000/\(boardId!)/getAllUsers"
        Alamofire.request(url, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let allUsers = data["response"]
                for user in allUsers.arrayValue {
                    if user["users_id"].stringValue != userId {
                        thisUser = user["users_id"].stringValue
                        let newUrl = "http://localhost:5000/byId/\(user["users_id"].intValue)"
                        Alamofire.request(newUrl, method: .get).responseJSON { response in
                            if let data : JSON = JSON(response.result.value) {
                                let response = data["response"]
                                let user = response["username"]
                                print(user)
                                print(thisUser)
                                self.userNameArray.append(user.stringValue)
                                self.userIdArray.append(thisUser)
                                self.userPhotoArray.append("images/users/\(thisUser).jpg")

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
        let alert = UIAlertController(title: "Are you sure?", message: "This will delete board permanently", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            let boardId = self.defaults.string(forKey: "boardId")
            let url = "http://localhost:5000/\(boardId!)/deleteBoard"
            Alamofire.request(url, method: .delete).responseJSON { response in
                switch response.result {
                case .success:
                    print("Succeeded")
                case .failure(let error):
                    print(error)
                }
//                let vc = self.navigationController?.viewControllers.filter({$0 is BoardViewController}).first
//                self.navigationController?.popToViewController(vc!, animated: true)
            }

        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
