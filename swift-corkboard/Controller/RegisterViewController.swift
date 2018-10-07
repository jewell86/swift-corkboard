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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.email.delegate = self
        self.username.delegate = self
        self.password.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            self.defaults.set(token.stringValue, forKey: "token")
            self.defaults.set(userId.stringValue, forKey: "userId")
            print(token)
            if token == JSON.null {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Couldn't Register", message: "Please check all fields and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Error: \(error)")
            } else {
                print("Registration Success!")
                let alert = UIAlertController(title: "Success", message: "You are registered!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go to my boards", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                self.navigationController!.pushViewController(controller!, animated: true)

        }
    }

     }



}
