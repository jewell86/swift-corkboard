//
//  MainViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/6/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let notes = [ "Hello there", "groceries", "todo list", "its me", "gagin", "fuck", "shit", "poop", "sexxxx" ]

    //TODO: Set IBOutlets & IBActions
    @IBOutlet weak var allBoardsTableView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set delegates
        allBoardsTableView.delegate = self
        allBoardsTableView.dataSource = self
        
        //Register NoteCell.xib file here
        allBoardsTableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: "noteCell")
        //Set size to auto layout
        if let flowLayout = allBoardsTableView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        }
        
        var isHeightCalculated: Bool = false
        
        func preferredLayoutAttributesFittingAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            //Exhibit A - We need to cache our calculation to prevent a crash.
            if !isHeightCalculated {
//                setNeedsLayout()
//                layoutIfNeeded()
                let size = allBoardsTableView.systemLayoutSizeFitting(layoutAttributes.size)
                var newFrame = layoutAttributes.frame
                newFrame.size.width = CGFloat(ceilf(Float(size.width)))
                layoutAttributes.frame = newFrame
                isHeightCalculated = true
            }
            return layoutAttributes
        }
        
        //GET REQUEST FOR ALL BOARDS FOR USER
 
            Alamofire.request("http://localhost:5000/1/main", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let data : JSON = JSON(response.result.value!)
                print("DATA!!!!!!!")
            print(data)
            }

//            let token = data["token"]
//            let error = data["error"]
//            print(token)
//            if token == JSON.null {
//                print("Error: \(error)")
//            } else {
//                print("Login Success!")
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//                self.present(mainViewController, animated: true, completion: nil)            }
//            }

        //populate buttons for each board w/ id#
        //link each button to boardViewController
        //make get request from boardViewController to get all board info
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCell
        
        cell.noteTextInput.text = notes[indexPath.row]
//        print(indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

