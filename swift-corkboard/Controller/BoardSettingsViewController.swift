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
import iOSDropDown

class BoardSettingsViewController: UIViewController, UserCellDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
 
    @IBOutlet var dropDown: DropDown!
    
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
        populateUsers()

        dropDown.optionArray = [String]()
        dropDown.optionIds = [Int]()
        dropDown.didSelect { (selectedText, index, id) in
            print("SELECTED")
            print(selectedText)
            print(id)
            
            let boardId = self.defaults.string(forKey: "boardId")
            let userId = id
            let url = "https://powerful-earth-36700.herokuapp.com/\(boardId!)/addUser"
            Alamofire.request(url, method: .post, parameters: ["id" : userId]).responseJSON { response in
                switch response.result {
                case .success:
                    print("Succeeded")
                    let alert = UIAlertController(title: "Success!", message: "\(String(describing: selectedText)) added!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        self.listAllUsers()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Ut oh!", message: "\(String(describing: selectedText)) could not be added!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.dropDown.hideList()
                }
                }
                }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
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
        cell.delegate = self
        return cell
    }
    
    func removeButton(cell: UserCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let boardId = defaults.string(forKey: "boardId")
        let userId = cell.usersId
        let url = "https://powerful-earth-36700.herokuapp.com/\(boardId!)/\(userId)/removeUser"
        Alamofire.request(url, method: .delete).responseJSON { response in
            self.listAllUsers()
            switch response.result {
            case .success:
                print("Succeeded")
                let alert = UIAlertController(title: "Success!", message: "User deleted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                }))
                self.present(alert, animated: true, completion: nil)

            case .failure(let error):
                print(error)
            }
        }

    }
    
    func populateUsers() {
        let url = "https://powerful-earth-36700.herokuapp.com/getAll"
        Alamofire.request(url, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let users = data["response"]
                for user in users.arrayValue {
                    let thisUser = user["username"]
                    let id = user["id"]
                    self.dropDown.optionArray.append(thisUser.string!)
                    self.dropDown.optionIds?.append(id.int!) 
                }
            }
        }
    }


    //RENAME BOARD
    @IBOutlet var renameBoardInput: UITextField!
    @IBAction func renameBoardButton(_ sender: UIButton) {
        let boardId = defaults.string(forKey: "boardId")
        let newName = renameBoardInput.text!
        let url = "https://powerful-earth-36700.herokuapp.com/\(boardId!)/renameBoard"
        let params : [String : Any] = ["title" : newName]
        Alamofire.request(url, method: .patch, parameters: params).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let data = data["response"]
                let title = data["title"]
                self.defaults.set("\(title)", forKey: "title")
                switch response.result {
                case .success:
                    self.navigationController?.popViewController(animated: true);
                    print("Succeeded")
                case .failure(let error):
                    print(error)
                }
                self.renameBoardInput.text = ""
        }
        }
    }
    
    //POPULATE ALL BOARD USERS
    func listAllUsers() {
        userNameArray = [String]()
        print(userNameArray.count)
        userPhotoArray = [String]()
        userIdArray = [String]()
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let params : [String : Any] = ["boards_id": boardId]
        let url = "https://powerful-earth-36700.herokuapp.com/\(boardId!)/getAllUsers"
        Alamofire.request(url, method: .get).responseJSON { response in
            if let data : JSON = JSON(response.result.value) {
                let allUsers = data["response"]
                for user in allUsers.arrayValue {
                    if user["users_id"].stringValue != userId {
                        var thisUser = user["users_id"].stringValue
                        let newUrl = "https://powerful-earth-36700.herokuapp.com/byId/\(user["users_id"].intValue)"
                        Alamofire.request(newUrl, method: .get).responseJSON { response in
                            if let data : JSON = JSON(response.result.value) {
                                let response = data["response"]
                                let user = response["username"]
                                self.userNameArray.append(user.stringValue)
                                self.userIdArray.append(thisUser)
                                self.userPhotoArray.append("images/users/\(thisUser).jpg")
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
        
    
    //DELETE BOARD
    @IBAction func deleteBoardButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will delete board permanently", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in
            let boardId = self.defaults.string(forKey: "boardId")
            let url = "https://powerful-earth-36700.herokuapp.com/\(boardId!)/deleteBoard"
            Alamofire.request(url, method: .delete).responseJSON { response in
                switch response.result {
                case .success:
                    print("Succeeded")
                case .failure(let error):
                    print(error)
                }
            }
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}















