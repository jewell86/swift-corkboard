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

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //DECLARE GLOBAL VARIABLES
    var boardArray : [BoardIcon] = [BoardIcon]()
    let defaults = UserDefaults.standard

    //VAR FOR COLLECTIONVIEW
    @IBOutlet var allBoardsTableView: UICollectionView!
    
    //VIEWDIDLOAD - FIRST FUNC CALLED
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //SET DELEGATES
        allBoardsTableView.delegate = self
        allBoardsTableView.dataSource = self
        //REGISTER XIB FILE
        allBoardsTableView.register(UINib(nibName: "BoardCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "boardCellCollectionViewCell")
        //CALL OTHER FUNCS
        configureCollectionView()
        renderBoards()
    }
    
    //CREATE CELLS BY PASSING DATA FROM BOARD ARRAY INTO BOARD CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCellCollectionViewCell", for: indexPath) as! BoardCellCollectionViewCell
        cell.boardCellLabel.text = boardArray[indexPath.row].title
        cell.tag = indexPath.row
        return cell
    }
    
    //CLICK ON BOARD FUNC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = boardArray[indexPath.row]
        let title = id.title
        let boardId = id.boards_id
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let boardViewController = storyBoard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        boardViewController.name = title
        boardViewController.id = boardId
        self.present(boardViewController, animated: true, completion: nil)
    }
    
    //DETERMINE CELL COUNT
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardArray.count
    }
    
    //?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //SET SIZE OF COLLECTION VIEW ROWS
    func configureCollectionView() {
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
            self.configureCollectionView()
            self.allBoardsTableView.reloadData()
        }
    }
    
    //ADD NEW BOARD BUTTON PRESSED SHOW ALERT
    @IBAction func addNewBoard(_ sender: Any) {        
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
    
    //ADD NEW BOARD DB CALL
    func addNewBoard(title: String) {
        let userId = defaults.string(forKey: "userId")
        let url = "http://localhost:5000/\(userId!)"
        Alamofire.request(url, method: .post, parameters: ["title" : title], encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            self.renderBoards()
        }
    }
    
    //LOGOUT BUTTON PRESSED
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        KeychainWrapper.standard.removeObject(forKey: "token")
        KeychainWrapper.standard.removeObject(forKey: "token")
        
        let mainView = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = mainView
    }
}


