//
//  RegisterViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/6/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class RegisterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var secondPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.email.delegate = self
        self.username.delegate = self
        self.password.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registerPressed((Any).self)
        return true
    }
    
     @IBAction func registerPressed(_ sender: Any) {
        SVProgressHUD.show()
        Alamofire.request("https://powerful-earth-36700.herokuapp.com/register", method: .post, parameters: [ "first_name": firstName.text!, "last_name": lastName.text!, "username": username.text!, "email": email.text!,  "password": password.text! ],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let data : JSON = JSON(response.result.value!)
            let token = data["token"]
            let userId = data["user_id"]
            let error = data["error"]
            let username = "\(self.username.text!)"

            self.defaults.set(token.stringValue, forKey: "token")
            self.defaults.set(userId.stringValue, forKey: "userId")
            self.defaults.set(username, forKey: "username")

            print(token)
            if token == JSON.null {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Couldn't Register", message: "Please check all fields and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Error: \(error)")
            } else {
                print("Registration Success!")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Success", message: "You are registered!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
                    self.lastName.text = ""
                    self.firstName.text = ""
                    self.email.text = ""
                    self.password.text = ""
                    self.username.text = ""
                    self.secondPassword.text = ""
                    let _ : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                    self.navigationController!.pushViewController(controller!, animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
     }
}
