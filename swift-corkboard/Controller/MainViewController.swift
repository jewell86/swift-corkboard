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
    
    let notes = [ "Hello there", "groceries", "todo list", "its me", "again", "meme", "hay", "its a note", "poop" ]
    
    var boardArray : [BoardIcon] = [BoardIcon]()
    
    //ADD NEW BOARD BUTTON
    @IBAction func addNewBoard(_ sender: Any) {
 
        let alert = UIAlertController(title: "Add A New Board", message: "Enter Board Name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))

        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            } // Force unwrapping because we know it exists.
            self.addNewBoard(title: textField.text!)
            print("Text field: \(String(describing: textField.text))")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var allBoardsTableView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //TODO: Set delegates
    allBoardsTableView.delegate = self
    allBoardsTableView.dataSource = self
        
    //TODO: Register NoteCell.xib file here
    allBoardsTableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: "noteCell")
    configureCollectionView()
    renderBoards()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCell
//        print(boardArray[indexPath.row].title)
        
        cell.noteTextInput.text = boardArray[indexPath.row].title

        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardArray.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCollectionView() {
        //TODO: Set size to auto layout
        if let flowLayout = allBoardsTableView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        }
        var isHeightCalculated: Bool = false
        func preferredLayoutAttributesFittingAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
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
    }
    
    func renderBoards() {
        self.boardArray = [BoardIcon]()
        Alamofire.request("http://localhost:5000/1/main", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            let data : JSON = JSON(response.result.value!)
            let allBoards = data["response"]
            for board in allBoards.arrayValue {
                let newBoard = BoardIcon()
                newBoard.boards_id = board["boards_id"]
                newBoard.added_by = board["added_by"]
                newBoard.title = board["title"].stringValue
                print(newBoard.title)
                self.boardArray.append(newBoard)
            }
            self.configureCollectionView()
            self.allBoardsTableView.reloadData()
        }

    }
    
    func addNewBoard(title: String) {
        Alamofire.request("http://localhost:5000/1", method: .post, parameters: ["title" : title], encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
//            let data : JSON = JSON(response.result.value!)
            self.renderBoards()
        }
    }



}

