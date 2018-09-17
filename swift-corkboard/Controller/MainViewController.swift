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

class MainViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //DECLARE GLOBAL VARIABLES
    var boardArray : [BoardIcon] = [BoardIcon]()
    let defaults = UserDefaults.standard

    //VAR FOR COLLECTIONVIEW
    @IBOutlet weak var allBoardsTableView: UICollectionView!
    
    //VIEWDIDLOAD - FIRST FUNC CALLED
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.allBoardsTableView?.allowsSelection = true
//        self.allBoardsTableView?.allowsMultipleSelection = false
        
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
    
    //CREATE & CONFIGURE CELLS FOR COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCellCollectionViewCell", for: indexPath) as! BoardCellCollectionViewCell
        cell.boardCellLabel.text = boardArray[indexPath.row].title
        cell.tag = indexPath.row
        return cell
    }
    
    //CLICK ON BOARD FUNC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = boardArray[indexPath.row]
        let boardId = id.title
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let boardViewController = storyBoard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        boardViewController.name = boardId
        self.present(boardViewController, animated: true, completion: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! BoardViewController //Your ViewController class
//        if let cell = sender as? UICollectionViewCell,
//            let indexPath = self.allBoardsTableView.indexPath(for: cell){
//
//            let id = boardArray[indexPath.row]
//            let boardId = id.title
//            print(boardId)
//            vc.name = boardId
//        }
//    }
    
    
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
    
    //RENDER & DISPLAY ALL BOARDS FROM DB TO COLLECTION VIEW
    func renderBoards() {
        let userId = defaults.string(forKey: "userId")
        print("here is renderboards func userid from storage")
        print(userId!)
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
    @IBAction func logoutButton(_ sender: Any) {
        self.defaults.removeObject(forKey: "token")
        self.defaults.removeObject(forKey: "userId")
    }
}


