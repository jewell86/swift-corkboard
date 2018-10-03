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
import SwiftKeychainWrapper

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    //DECLARE GLOBAL VARIABLES
    var boardArray : [BoardIcon] = [BoardIcon]()
    let defaults = UserDefaults.standard

    //VAR FOR COLLECTIONVIEW
    @IBOutlet var allBoardsTableView: UICollectionView!
    
    //VIEWDIDLOAD - FIRST FUNC CALLED
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET DELEGATES
        allBoardsTableView.delegate = self
        allBoardsTableView.dataSource = self
        
        //REGISTER XIB FILE
        allBoardsTableView.register(UINib(nibName: "BoardCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "boardCellCollectionViewCell")
        
        //SET LONGPRESS RECOGNIZER
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        allBoardsTableView.addGestureRecognizer(longPressGesture)
        
        //CALL OTHER FUNCS
        renderBoards()
    }
    
    //CREATE CELLS BY PASSING DATA FROM BOARD ARRAY INTO BOARD CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCellCollectionViewCell", for: indexPath) as! BoardCellCollectionViewCell
        cell.boardCellLabel.text = boardArray[indexPath.row].title
        cell.tag = indexPath.row
        cell.layer.cornerRadius = 7.0
        cell.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: -5, height: 5)
        cell.layer.shadowRadius = 0.5

        return cell
    }
    
    //CLICK ON BOARD FUNC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = boardArray[indexPath.row]
        let title = id.title
        let boardId = id.boards_id
        self.defaults.set("\(boardId)", forKey: "boardId")
        self.defaults.set("\(title)", forKey: "title")
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let boardViewController = storyBoard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        boardViewController.name = title
        boardViewController.id = boardId
        self.navigationController!.pushViewController(boardViewController, animated: true)
    }
    
    //DETERMINE CELL COUNT
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardArray.count
    }
    
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //RENDER ALL BOARDS FROM DB TO SELF.BOARD ARRAY
    func renderBoards() {
        let userId = defaults.string(forKey: "userId")
        let url = "http://localhost:5000/\(userId!)/main"
        self.boardArray = [BoardIcon]()
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            if let data : JSON = JSON(response.result.value) {
            let allBoards = data["response"]
            for board in allBoards.arrayValue {
                let newBoard = BoardIcon()
                newBoard.boards_id = board["boards_id"]
                newBoard.added_by = board["added_by"]
                newBoard.title = board["title"].stringValue
                self.boardArray.append(newBoard)
                }
            }
            self.allBoardsTableView.reloadData()
        }
    }
    
    //ADD NEW BOARD BUTTON PRESSED SHOW ALERT
    
    @IBAction func addNewBoard(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Add A New Board", message: "Enter Board Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            self.addNewBoard(title: textField.text!)
            print("Text field: \(String(describing: textField.text))")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func settingsButton(_ sender: UIBarButtonItem) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserSettingsViewController")
        self.navigationController!.pushViewController(controller!, animated: true)
    }
    //ADD NEW BOARD DB CALL
    func addNewBoard(title: String) {
        let userId = defaults.string(forKey: "userId")
        let url = "http://localhost:5000/\(userId!)"
        Alamofire.request(url, method: .post, parameters: ["title" : title], encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            self.renderBoards()
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////  COLLECTION VIEW DELEGATE METHODS ///////
    ///////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempvalue1 = boardArray[sourceIndexPath.row]
        print("MOVING!!!")
        boardArray.remove(at: sourceIndexPath.row)
        boardArray.insert(tempvalue1, at: destinationIndexPath.row)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //////////////////// GESTURE METHODS/////////
    ////////////////////////////////////////////////////////////////////////////////
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = allBoardsTableView.indexPathForItem(at: gesture.location(in: allBoardsTableView)) else {
                break
            }
            allBoardsTableView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            allBoardsTableView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            allBoardsTableView.endInteractiveMovement()
        default:
            allBoardsTableView.cancelInteractiveMovement()
        }
    }
    
    
    
}


