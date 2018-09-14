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



}

