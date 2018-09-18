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
import FirebaseFirestore
import Firebase
import FirebaseStorage

class BoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    @IBOutlet weak var boardCellLabel: UILabel!
    
    //DECLARE GLOBAL VARIABLES
    var itemArray : [AnyObject] = [AnyObject]()
    let defaults = UserDefaults.standard
    
    var name : String = ""
    var id : Any = ""
    

    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET DELEGATES
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
//        imagePickerDelegate.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        boardCellLabel.text! = name
        self.defaults.set("\(self.id)", forKey: "boardId")

        print("ITS THE BOARD ID RIGHT HRRRRR")
        let boardId = defaults.string(forKey: "boardId")
        print(boardId!)

        //REGISTER CELL XIBS
        itemCollectionView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellWithReuseIdentifier: "noteViewCell")
        itemCollectionView.register(UINib(nibName: "ListCell", bundle: nil), forCellWithReuseIdentifier: "listCell")
        itemCollectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        itemCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        itemCollectionView.register(UINib(nibName: "WebpageCell", bundle: nil), forCellWithReuseIdentifier: "webpageCell")
        
        //CALL OTHER FUNCS
        configureCollectionView()
        renderItems()
        renderImages()
    }
    
    //RENDER ALL ITEM CELLS TO PAGE FROM ITEM ARRAY
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if ((itemArray[indexPath.row] as? BoardNote) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
            cell.content.text = (itemArray[indexPath.row] as! BoardNote).content
            print("made note cell")
            return cell
        } else if ((itemArray[indexPath.row] as? BoardList) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCell
            cell.content.text = (itemArray[indexPath.row] as! BoardList).content
            print("made list cell")
            return cell

        } else if ((itemArray[indexPath.row] as? BoardImage) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
            cell.titleLabel.text = (itemArray[indexPath.row] as! BoardImage).content
            return cell

        } else if ((itemArray[indexPath.row] as? BoardVideo) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
            cell.titleLabel.text = (itemArray[indexPath.row] as! BoardVideo).content
            return cell

        } else if ((itemArray[indexPath.row] as? BoardWebpage) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
            cell.titleLabel.text = (itemArray[indexPath.row] as! BoardWebpage).content
            print("made a webpage cell")
            return cell

        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
        return cell
    }
    
    //DETERMINE CELL COUNT
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //OVERRIDE MEMORY THINGY
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //BACK BUTTON FUNCTIONALITY
    @IBAction func backButton(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    //SET SIZE OF COLLECTION VIEW
    func configureCollectionView() {
        if let flowLayout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        }
        var isHeightCalculated: Bool = false
        func preferredLayoutAttributesFittingAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            if !isHeightCalculated {
                //                setNeedsLayout()
                //                layoutIfNeeded()
                let size = itemCollectionView.systemLayoutSizeFitting(layoutAttributes.size)
                var newFrame = layoutAttributes.frame
                newFrame.size.width = CGFloat(ceilf(Float(size.width)))
                layoutAttributes.frame = newFrame
                isHeightCalculated = true
            }
            return layoutAttributes
        }
    }
    
    //RENDER ALL ITEMS INTO ITEM ARRAY FROM DB
    func renderItems() {
        let userId = defaults.string(forKey: "userId")
        let boardId = self.id   
        let url = "http://localhost:5000/\(userId!)/\(boardId)"
        self.itemArray = [AnyObject]()
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            if let data : JSON = JSON(response.result.value) {
                let allItems = data["response"]
                for item in allItems.arrayValue {
                    if item["type"] == "note"{
                        let noteItem = BoardNote()
                        noteItem.note_id = item["id"]
                        noteItem.itemType = item["type"].stringValue
                        noteItem.added_by = item["added_by"]
                        noteItem.link = item["link"]
                        noteItem.content = item["content"].stringValue
                        noteItem.board_id = item["board_id"]
                        noteItem.date_added = item["updated_at"]
                        self.itemArray.append(noteItem)
                    } else if item["type"] == "list" {
                        let listItem = BoardList()
                        listItem.list_id = item["id"]
                        listItem.itemType = item["type"].stringValue
                        listItem.added_by = item["added_by"]
                        listItem.link = item["link"]
                        listItem.content = item["content"].stringValue
                        listItem.board_id = item["board_id"]
                        listItem.date_added = item["updated_at"]
                        self.itemArray.append(listItem)
                    } else if item["type"] == "webpage" {
                        let webpageItem = BoardWebpage()
                        webpageItem.webpage_id = item["id"]
                        webpageItem.itemType = item["type"].stringValue
                        webpageItem.added_by = item["added_by"]
                        webpageItem.link = item["link"]
                        webpageItem.content = item["content"].stringValue
                        webpageItem.board_id = item["board_id"]
                        webpageItem.date_added = item["updated_at"]
                        self.itemArray.append(webpageItem)
                    }
                }
            }
            self.configureCollectionView()
            self.itemCollectionView.reloadData()
        }

    }
    
    //RENDER IMAGES FROM DB
    func renderImages() {
//        // Create a reference with an initial file path and name
//        let reference = Storage.storage().reference(withPath: "images/")
//        reference.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
//            if let _error = error{
//                print(_error)
//            } else {
//                if let _data  = data {
//                    print("ALL IMAGES")
//                    print(data)
//                    //                        let myImage:UIImage! = UIImage(data: _data)
//                    //                        success(myImage)
//                }
//            }
//        }
    }
    
    //ADD IMAGE BUTTON PRESSED
    @IBAction func addImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //SAVE IMAGE TO FIREBASE
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Double) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let directory = defaults.string(forKey: "boardId")
        let fileName = Date().timeIntervalSinceNow
        let imageRef = storageRef.child("images/\(directory!)/\(fileName).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.customMetadata = [
                    "itemType": "image",
                    "added_by": "1",
                    "content": "",
                    "board_id": "\(self.id)",
            ]
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                imageRef.downloadURL(completion: { (url, error) in
                    if let metadata = metadata {
                        return completionBlock( url, nil)
                    } else {
                        completionBlock(nil, error?.localizedDescription)
                    }
                })
            })
            
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                let percentage = (Double(progress.completedUnitCount) / Double(progress.totalUnitCount)) * 100
                progressBlock(percentage)
                })
                } else {
                completionBlock(nil, "Image not converted to data")
                }
            }
}


//DELEGATE EXTENSIONS FOR PHOTO UPLOADING
extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let imageUploadManager = BoardViewController()
            imageUploadManager.uploadImage(image, progressBlock: { (percentage) in
                print(percentage)
            }, completionBlock: { (fileURL, errorMessage) in
                print(fileURL)
                print(errorMessage)
            })
            
        }
    }
}

    


    /////////////////
    
        
        //CLICK ON ITEM FUNC
//        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//            let id = boardArray[indexPath.row]
//            let title = id.title
//            let boardId = id.boards_id
//            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let boardViewController = storyBoard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
//            boardViewController.name = title
//            boardViewController.id = boardId
//            self.present(boardViewController, animated: true, completion: nil)
//        }
//
//
//        //ADD NEW ITEM BUTTON PRESSED SHOW ALERT
//        @IBAction func addNewBoard(_ sender: Any) {
//            let alert = UIAlertController(title: "Add A New Board", message: "Enter Board Name", preferredStyle: .alert)
//            alert.addTextField { (textField) in
//                textField.text = ""
//            }
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//                guard let textField = alert?.textFields![0] else {
//                    return
//                }
//                self.addNewBoard(title: textField.text!)
//                print("Text field: \(String(describing: textField.text))")
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//
//        //ADD NEW ITEM DB CALL
//        func addNewBoard(title: String) {
//            let userId = defaults.string(forKey: "userId")
//            let url = "http://localhost:5000/\(userId!)"
//            Alamofire.request(url, method: .post, parameters: ["title" : title], encoding: JSONEncoding.default, headers: nil).responseJSON {
//                response in
//                self.renderBoards()
//            }
//        }
//}
