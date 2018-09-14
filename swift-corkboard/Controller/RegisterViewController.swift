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

class RegisterViewController: UIViewController {

    
    let defaults = UserDefaults.standard


    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     @IBAction func registerPressed(_ sender: Any) {
        SVProgressHUD.show()
        Alamofire.request("http://localhost:5000/register", method: .post, parameters: [ "first_name": firstName.text!, "last_name": lastName.text!, "username": username.text!, "email": email.text!,  "password": password.text! ],encoding: JSONEncoding.default, headers: nil).responseJSON {
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
                print("Error: \(error)")
            } else {
                print("Registration Success!")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMainView", sender: self)
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//                self.present(mainViewController, animated: true, completion: nil)            }
        }
    }
    
//    func loginRequest(){
     }
    

    

     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//    }


}
