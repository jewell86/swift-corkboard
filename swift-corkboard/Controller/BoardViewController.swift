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
import YPImagePicker
import GoogleMaps
import GooglePlaces
import CircleMenu

class BoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, GMSMapViewDelegate, CircleMenuDelegate {
    
    @IBOutlet var itemCollectionView: UICollectionView!
    
    //DECLARE GLOBAL VARIABLES
    var itemArray : NSMutableArray!
    let defaults = UserDefaults.standard
    let slp = SwiftLinkPreview()
    var name : String = ""
    var id : Any = ""
    var isGridView = true
    var config = YPImagePickerConfiguration()
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET DELEGATES
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        
        //DECLARE VARIABLES ETC
        itemCollectionView.dragInteractionEnabled = true
        let title = defaults.string(forKey: "title")
        itemArray = NSMutableArray()
        
        //SET LONGPRESS RECOGNIZER
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        itemCollectionView.addGestureRecognizer(longPressGesture)
        
        //REGISTER CELL XIBS
        itemCollectionView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellWithReuseIdentifier: "noteViewCell")
        itemCollectionView.register(UINib(nibName: "ListCell", bundle: nil), forCellWithReuseIdentifier: "listCell")
        itemCollectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        itemCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        itemCollectionView.register(UINib(nibName: "WebpageCell", bundle: nil), forCellWithReuseIdentifier: "webpageCell")
        itemCollectionView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellWithReuseIdentifier: "mapViewCell")
        
        //IMAGE PICKER
        config.library.mediaType = .photoAndVideo
        config.screens = [.library, .photo, .video]
        let picker = YPImagePicker(configuration: config)
        
        //GOOGLE MAPS
//        let key = "AIzaSyAXb0hDm-Sxe6rkj1dFoJRDhAGDhur2Ue8"
//        GMSServices.provideAPIKey(key)
       
        let button = CircleMenu(
            frame: CGRect(x: 200, y: 200, width: 50, height: 50),
            normalIcon:"button",
            selectedIcon:"button",
            buttonsCount: 5,
            duration: 0.5,
            distance: 100)
//        button.backgroundColor = UIColor.lightGrayColor()
        button.delegate = self
        button.layer.cornerRadius = button.frame.size.width / 2.0
        view.addSubview(button)

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
            cell.listTitle.text = (itemArray[indexPath.row] as! BoardList).link
//            cell.listItems.text = (itemArray[indexPath.row] as! BoardList).content
//            cell.listId = (itemArray[indexPath.row] as! BoardList).list_id
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
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: -5, height: 5)
            cell.layer.shadowRadius = 1            
            return cell
        } else if ((itemArray[indexPath.row] as? BoardVideo) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
            cell.titleLabel.text = (itemArray[indexPath.row] as! BoardVideo).content
            return cell
        } else if ((itemArray[indexPath.row] as? BoardWebpage) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
//            cell.imageTitle.text = (itemArray[indexPath.row] as! BoardWebpage).content
            cell.webpageId = (itemArray[indexPath.row] as! BoardWebpage).webpage_id
            cell.webpageUrl = (itemArray[indexPath.row] as! BoardWebpage).webpage_url
            cell.backgroundColor = UIColor.white
            let webpageView = cell.img
            let placeholderImage = UIImage(named: "angle-mask.png")
            webpageView?.sd_setImage(with: URL(string: "\((itemArray[indexPath.row] as! BoardWebpage).link)"), placeholderImage: placeholderImage)
            self.view.layoutIfNeeded()
            cell.layer.cornerRadius = 7.0
            cell.layer.masksToBounds = true
            return cell
        } else if ((itemArray[indexPath.row] as? BoardMap) != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapViewCell", for: indexPath) as! MapViewCell
            let camera = GMSCameraPosition.camera(withLatitude: 32.66, longitude: -122.33, zoom: 6.0)
            cell.myMapView.camera = camera
//            cell.myMapView.isMyLocationEnabled = true
//            cell.myMapView.animate(to: camera)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: 32.60, longitude: -122.33)
            marker.title = "Galvanize"
            marker.snippet = "Seattle"
            marker.map = cell.myMapView
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

    
    //DISMISS IMAGE SUBVIEW
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.alpha = 1
        UIView.animate(withDuration: 1.5, animations: {
            sender.view?.alpha = 0
            sender.view?.removeFromSuperview()
        })
    }
    
    //SELECT WEBPAGE, IMAGE, LIST FUNCTIONALITY
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        //IF WEBPAGE
        if (cell as? WebpageCell) != nil {
        let cell = collectionView.cellForItem(at: indexPath) as! WebpageCell
            let webItem = cell.webpageUrl
            let url = URL(string: "\(webItem)")
            UIApplication.shared.open(url!, options: [:])
        //IF IMAGE
        } else if (cell as? ImageCell) != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
            let imageView = cell.img as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
//            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.tabBar.isHidden = true
            //LIST CELL
        }  else if (cell as? ListCell) != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! ListCell
//            let listId = cell.listId
            let alert = UIAlertController(title: "Add List Item", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                guard let textField = alert?.textFields![0] else {
                    return
                }
//                self.addListItem(item: textField.text!, listId: listId)
                print("Text field: \(String(describing: textField.text))")
            }))
            print("TAP LIST")
            self.present(alert, animated: true, completion: nil)
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
        if let flowLayout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 200, height: 200)
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
        itemArray = NSMutableArray()
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
                        self.itemArray.add(noteItem)
                    } else if item["type"] == "list" {
                        let listItem = BoardList()
                        listItem.list_id = item["id"].stringValue
                        listItem.itemType = item["type"].stringValue
                        listItem.added_by = item["added_by"].stringValue
                        listItem.link = item["link"].stringValue
                        listItem.content = item["content"].stringValue
                        listItem.board_id = item["board_id"].stringValue
                        listItem.date_added = item["updated_at"].stringValue
                        self.itemArray.add(listItem)
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
                        self.itemArray.add(webpageItem)
                    } else if item["type"] == "image" {
                        let imageItem = BoardImage()
                        imageItem.image_id = item["id"].stringValue
                        imageItem.itemType = item["type"].stringValue
                        imageItem.added_by = item["added_by"].stringValue
                        imageItem.link = item["link"].stringValue
                        imageItem.content = item["content"].stringValue
                        imageItem.board_id = item["board_id"].stringValue
                        self.itemArray.add(imageItem)
                    }   else if item["type"] == "map" {
                        let mapItem = BoardMap()
                        mapItem.map_id = item["id"].stringValue
                        mapItem.itemType = item["type"].stringValue
                        mapItem.added_by = item["added_by"].stringValue
                        mapItem.link = item["link"].stringValue
                        mapItem.content = item["content"].stringValue
                        mapItem.board_id = item["board_id"].stringValue
                        self.itemArray.add(mapItem)
                    }
                }
            }
            self.itemCollectionView.reloadData()
        }
        }
    
////////////////////////////
//BUTTONS
///////////////////////////
    //BUTTON PHOTO
   func addImage() {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.uploadImage(photo.image, progressBlock: { (percentage) in
                    print(percentage)
                }, completionBlock: { (fileURL, errorMessage) in
                    print(errorMessage)
                })
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            } else if let video = items.singleVideo {
                self.uploadVideo(video: video.url)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    //BUTTON MAP
    func addMap() {
        let url = "http://localhost:5000/addItem"
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let params = [
            "itemType": "map",
            "added_by": Int(userId!),
            "link": "",
            "content": "",
            "board_id": Int(boardId!)
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }
    //BUTTON LIST
    func addList() {
        let alert = UIAlertController(title: "Create a list", message: "Enter List Title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            let url = "http://localhost:5000/addItem"
            let userId = self.defaults.string(forKey: "userId")
            let boardId = self.defaults.string(forKey: "boardId")
            let params = [
                "itemType": "list",
                "added_by": Int(userId!),
                "link": "\(textField.text!)",
                "content": "",
                "board_id": Int(boardId!)
                ] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
                self.renderItems()
            }
            print("Text field: \(String(describing: textField.text!))")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //BUTTON NOTE
    func addNote() {
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
    //BUTTON WEBPAGE
    func addWebsite() {
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
    
    //ADD LIST ITEM
    func addListItem(item: String, listId: String) {
        let url = "http://localhost:5000/updateItem"
        let listItem = "\(item) \n"
        let params = [
            "content": listItem,
            "id": Int(listId)
            ] as [String : Any]
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
        
    }
    
    //ADD IMAGE TO POSTGRESSQL DB
    func addImageToDB(filename : String) {
        let name = filename
        let boardId = defaults.string(forKey: "boardId")
        let userId = defaults.string(forKey: "userId")
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
    
    //ADD VIDEO TO FIREBASE
    func uploadVideo(video: URL) {
        let fileName = NSUUID().uuidString
        let boardId = defaults.string(forKey: "boardId")
        let userId = defaults.string(forKey: "userId")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let videoRef = storageRef.child("videos/\(boardId!)/\(fileName).jpg")
        let uploadTask = videoRef.putFile(from: video, metadata: nil) { metadata, error in
            if let error = error
            {
                //do error handle
            }
        }
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
    
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////  Collection veiw delegate and datasource methods ///////
    ///////////////////////////////////////////////////////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempvalue1 = itemArray.object(at: sourceIndexPath.row)
        print("MOVING!!!")
        itemArray.removeObject(at: sourceIndexPath.row)
        itemArray.insert(tempvalue1, at: destinationIndexPath.row)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //////////////////// Gesture method for updating the cell in collection view//////////
    ////////////////////////////////////////////////////////////////////////////////
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = itemCollectionView.indexPathForItem(at: gesture.location(in: itemCollectionView)) else {
                break
            }
            itemCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            itemCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            itemCollectionView.endInteractiveMovement()
        default:
            itemCollectionView.cancelInteractiveMovement()
        }
    }
    
    var buttons = [ "button_website", "button_note", "button_list", "button_map", "button_photo" ]
    
    //CIRCLE MENU
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
//        button.image = items[atIndex]
        
        button.setImage(UIImage(named: buttons[atIndex]), for: .normal)
        
        // set highlited image
        let highlightedImage = UIImage(named: buttons[atIndex])?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
//        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
        if atIndex == 0 {
            addWebsite()
        } else if atIndex == 1 {
            addNote()
        } else if atIndex == 2 {
            addList()
        } else if atIndex == 3 {
            addMap()
        } else if atIndex == 4 {
           addImage()
        }
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
    }

    
    
    
}



