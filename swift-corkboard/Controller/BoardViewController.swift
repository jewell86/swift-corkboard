//
//  BoardViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/11/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BoardViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var boardCellLabel: UILabel!
    
    var name : String = ""
    var id : Any = ""
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        boardCellLabel.text! = name
        renderItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //BACK BUTTON
    @IBAction func backButton(_ sender: UIButton) {
        print("hi")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(mainViewController, animated: true, completion: nil)
        
    }
    
    //RENDER ALL BOARD ITEMS
    func renderItems() {
        let userId = defaults.string(forKey: "userId")
        let boardId = self.id
        let url = "http://localhost:5000/\(userId!)/\(boardId)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            if let data : JSON = JSON(response.result.value) {
            print(data)
            }
        }
    }
    

}
