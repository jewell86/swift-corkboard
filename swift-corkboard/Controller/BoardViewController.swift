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
import FirebaseUI
import PusherSwift
import SwiftLinkPreview

class BoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    var longPressGesture: UILongPressGestureRecognizer!
    
    @IBOutlet var itemCollectionView: UICollectionView!
    @IBOutlet var boardCellOutlet: UILabel!
    
    //DECLARE GLOBAL VARIABLES
    var itemArray : [AnyObject] = [AnyObject]()
    let defaults = UserDefaults.standard
    let slp = SwiftLinkPreview()
    
    var name : String = ""
    var id : Any = ""
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET DELEGATES
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        //        itemCollectionView.dragInteractionEnabled = true
        //        itemCollectionView.dropDelegate = self
        //        itemCollectionView.dragDelegate = self
        //        itemCollectionView.reorderingCadence = .fast //default value - .immediate
        let title = defaults.string(forKey: "title")
        boardCellOutlet.text! = "\(title)"
        //self.defaults.set("\(self.id)", forKey: "boardId")
        
        //REGISTER CELL XIBS
        itemCollectionView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellWithReuseIdentifier: "noteViewCell")
        itemCollectionView.register(UINib(nibName: "ListCell", bundle: nil), forCellWithReuseIdentifier: "listCell")
        itemCollectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        itemCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        itemCollectionView.register(UINib(nibName: "WebpageCell", bundle: nil), forCellWithReuseIdentifier: "webpageCell")
        
        //CALL OTHER FUNCS
        configureCollectionView()
        renderItems()
        
    }
    
    //RENDER ALL ITEM CELLS TO PAGE FROM ITEM ARRAY
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if ((itemArray[indexPath.row] as? BoardNote) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
            cell.content.text = (itemArray[indexPath.row] as! BoardNote).content
            cell.noteId = (itemArray[indexPath.row] as! BoardNote).note_id
            print("made note cell")
            return cell
        } else if ((itemArray[indexPath.row] as? BoardList) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCell
            cell.content.text = (itemArray[indexPath.row] as! BoardList).content
            print("made list cell")
            return cell
        } else if ((itemArray[indexPath.row] as? BoardImage) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
            cell.imageTitle.text = (itemArray[indexPath.row] as! BoardImage).content
            cell.imageId = (itemArray[indexPath.row] as! BoardImage).image_id
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("\((itemArray[indexPath.row] as! BoardImage).link)")
            let imageView = cell.img
            let placeholderImage = UIImage(named: "angle-mask.png")
            imageView?.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            return cell
        } else if ((itemArray[indexPath.row] as? BoardVideo) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
            cell.titleLabel.text = (itemArray[indexPath.row] as! BoardVideo).content
            return cell
        } else if ((itemArray[indexPath.row] as? BoardWebpage) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
            cell.imageTitle.text = (itemArray[indexPath.row] as! BoardWebpage).content
            cell.webpageId = (itemArray[indexPath.row] as! BoardWebpage).webpage_id
            cell.webpageUrl = (itemArray[indexPath.row] as! BoardWebpage).webpage_url
            let webpageView = cell.img
            let placeholderImage = UIImage(named: "angle-mask.png")
            webpageView?.sd_setImage(with: URL(string: "\((itemArray[indexPath.row] as! BoardWebpage).link)"), placeholderImage: placeholderImage)
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
    
    //DRAG & DROP
//    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
//    {
//        let items = coordinator.items
//        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
//        {
//            var dIndexPath = destinationIndexPath
//            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
//            {
//                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
//            }
//            collectionView.performBatchUpdates({
//                self.itemArray.remove(at: sourceIndexPath.row)
//                self.itemArray.insert(item.dragItem.localObject as! String as AnyObject, at: dIndexPath.row)
//                collectionView.deleteItems(at: [sourceIndexPath])
//                collectionView.insertItems(at: [dIndexPath])
//            })
//            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
//        }
//    }
    
    //SELECT WEBPAGE FUNCTIONALITY
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if (cell as? WebpageCell) != nil {
        let cell = collectionView.cellForItem(at: indexPath) as! WebpageCell
            let webItem = cell.webpageUrl
            let url = URL(string: "\(webItem)")
            UIApplication.shared.open(url!, options: [:])
        } else if (cell as? ImageCell) != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
            let imageView = cell.img as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
//            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
//            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    //BACK BUTTON FUNCTIONALITY
    @IBAction func backButton(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    //SET SIZE OF COLLECTION VIEW
    func configureCollectionView() {
        print("itemCollection")
        print(self.itemCollectionView)
        if let flowLayout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        }
        print("itemCollection")
        print(self.itemCollectionView)
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
        self.itemArray = [AnyObject]()
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let url = "http://localhost:5000/\(userId!)/\(boardId!)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            if let data : JSON = JSON(response.result.value) {
                let allItems = data["response"]
                for item in allItems.arrayValue {
                    if item["type"] == "note"{
                        let noteItem = BoardNote()
                        noteItem.note_id = item["id"].stringValue
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
                        webpageItem.webpage_id = item["id"].stringValue
                        webpageItem.itemType = item["type"].stringValue
                        webpageItem.added_by = item["added_by"].stringValue
                        webpageItem.link = item["link"].stringValue
                        webpageItem.content = item["content"].stringValue
                        webpageItem.board_id = item["board_id"].stringValue
                        webpageItem.date_added = item["updated_at"].stringValue
                        webpageItem.webpage_url = item["webpage_url"].stringValue
                        self.itemArray.append(webpageItem)
                    } else if item["type"] == "image" {
                        let imageItem = BoardImage()
                        imageItem.image_id = item["id"].stringValue
                        imageItem.itemType = item["type"].stringValue
                        imageItem.added_by = item["added_by"].stringValue
                        imageItem.link = item["link"].stringValue
                        imageItem.content = item["content"].stringValue
                        imageItem.board_id = item["board_id"].stringValue
                        self.itemArray.append(imageItem)
                    }
                }
            }
            self.itemCollectionView.reloadData()
        }
    }
    
    //MAKE DRAGGABLE
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
    //ADD IMAGE BUTTON PRESSED
    @IBAction func addImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //IMAGE PICKER CONTROLLER
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            self.uploadImage(image, progressBlock: { (percentage) in
                print(percentage)
            }, completionBlock: { (fileURL, errorMessage) in
                print(errorMessage)
            })
        }
    }
    
    //SAVE IMAGE TO FIREBASE
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Double) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let boardId = defaults.string(forKey: "boardId")
        let userId = defaults.string(forKey: "userId")
        let fileName = NSUUID().uuidString
        let imageRef = storageRef.child("images/\(boardId!)/\(fileName).jpg")
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.customMetadata = [
                    "itemType": "image",
                    "added_by": "\(userId!)",
                    "content": "TITLE",
                    "board_id": "\(boardId!)",
            ]
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                imageRef.downloadURL(completion: { (url, error) in
                    if let metadata = metadata {
                        print("here's metadata")
                        print(metadata)
                        self.addImageToDB(filename: fileName)
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
    
    //ADD IMAGE TO POSTGRESSQL DB
    func addImageToDB(filename : String) {
        let name = filename
        let boardId = defaults.string(forKey: "boardId")
        let userId = defaults.string(forKey: "userId")
//        let imageItem = BoardImage()
        let params = [
            "itemType": "image",
            "added_by": Int(userId!),
            "link": "images/\(String(describing: boardId!))/\(String(describing: name)).jpg",
            "content": "TITLE",
            "board_id": Int(boardId!)
            ] as [String : Any]
        let url = "http://localhost:5000/addItem"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
            }
    }
    
    //ADD BLANK NOTE TO POSTGRESQL DB
    @IBAction func addNote(_ sender: UIButton) {
        let url = "http://localhost:5000/addItem"
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let params = [
            "itemType": "note",
            "added_by": Int(userId!),
            "link": "",
            "content": "",
            "board_id": Int(boardId!)
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }
    
    //ADD WEBPAGE BUTTON
    @IBAction func addWebsite(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add A Website", message: "Enter full website address", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "http://www."
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            self.getWebsiteThumbnail(url: textField.text!)
            
            print("Text field: \(String(describing: textField.text!))")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //CREATE WEBPAGE ITEM
    func getWebsiteThumbnail(url: String) {
        slp.preview(
            "\(url)",
            onSuccess: { result in
                print(result)
                let imageIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "image")!)
                let image = result[imageIndex!].value
                let titleIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "title")!)
                let title = result[titleIndex!].value
                let urlIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "url")!)
                let webpageUrl = result[urlIndex!].value
                
                self.addWebsiteToDatabase(title: title as! String, image: image as! String, webpageUrl: webpageUrl as! URL)
            },
            onError: { error in
                print("\(error)")
            }
            )
        }
    
    //ADD WEBSITE TO DB
    func addWebsiteToDatabase(title: String, image: String, webpageUrl: URL) {
        let url = "http://localhost:5000/addItem"
        let userId = self.defaults.string(forKey: "userId")
        let boardId = self.defaults.string(forKey: "boardId")
        let params = [
            "itemType": "webpage",
            "added_by": Int(userId!),
            "link": "\(image)",
            "content": "\(title)",
            "board_id": Int(boardId!),
            "webpage_url": "\(webpageUrl)"
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }
}

// MARK: - UICollectionViewDragDelegate Methods
//extension BoardViewController : UICollectionViewDragDelegate
//{
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
//    {
//        let item = self.itemArray[indexPath.row]
//        let itemProvider = NSItemProvider(object: item as! NSObject as! NSItemProviderWriting)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
//        dragItem.localObject = item
//        return [dragItem]
//    }
//
//    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//    {
//        let item = self.itemArray[indexPath.row]
//        let itemProvider = NSItemProvider(object: item as! NSObject as! NSItemProviderWriting)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
//        dragItem.localObject = item
//        return [dragItem]
//    }
//
//    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
//    {
//            let previewParameters = UIDragPreviewParameters()
//            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 25, y: 25, width: 120, height: 120))
//            return previewParameters
//    }
//}
//
//// MARK: - UICollectionViewDropDelegate Methods
//extension BoardViewController : UICollectionViewDropDelegate
//{
//    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
//    {
//        return session.canLoadObjects(ofClass: NSString.self)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
//    {
//
//            if collectionView.hasActiveDrag
//            {
//                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//            }
//            else
//            {
//                return UICollectionViewDropProposal(operation: .forbidden)
//            }
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//    {
//        let destinationIndexPath: IndexPath
//        if let indexPath = coordinator.destinationIndexPath
//        {
//            destinationIndexPath = indexPath
//        }
//        else
//        {
//            // Get last index path of table view.
//            let section = collectionView.numberOfSections - 1
//            let row = collectionView.numberOfItems(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        switch coordinator.proposal.operation
//        {
//        case .move:
//            self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
//            break
//
//        default:
//            return
//        }
//    }
//    }
