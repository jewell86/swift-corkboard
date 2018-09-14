//
//  LoginViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/6/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var params : [String : String] = [ "username": "jewell86", "password": "C@tscratch12" ]
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        Alamofire.request("http://localhost:5000/login", method: .post, parameters: [ "username": usernameTextField.text!, "password": passwordTextField.text! ],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let data : JSON = JSON(response.result.value!)
            let token = data["token"]
            let userId = data["user_id"]
            let error = data["error"]
            print(userId)
            print(token)
            if token == JSON.null {
                print("Error: \(error)")
                SVProgressHUD.dismiss()
            } else {
                print("Login Success!")
                SVProgressHUD.dismiss()
//                self.performSegue(withIdentifier: "goToMainView", sender: self)
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.present(mainViewController, animated: true, completion: nil)            }
        }
    }
    
    func loginRequest(){
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
