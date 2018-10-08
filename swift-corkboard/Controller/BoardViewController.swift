//
//  BoardViewController.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/11/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

//IMPORT LIBRARIES
import UIKit
import AVFoundation
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
import Persei
import SVProgressHUD

class BoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    //COLLECTION VIEW OUTLET
    @IBOutlet var itemCollectionView: UICollectionView!
    
    //DECLARE GLOBAL VARIABLES
    var itemArray = [BoardItem]()
    let defaults = UserDefaults.standard
    let slp = SwiftLinkPreview()
    var name : String = ""
    var id : Any = ""
    var isGridView = true
    var config = YPImagePickerConfiguration()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
    let menu = MenuView()
    
    //PULL DOWN BUTTON
    let pullButton = UIButton()

    var locationManager = CLLocationManager()
    
    func navigationController(_ navigationController: UINavigationController, willShow BoardViewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow BoardViewController: UIViewController, animated: Bool) {
    }
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET DELEGATES
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        menu.delegate = self
        navigationController?.delegate = self
        
        //DECLARE VARIABLES
        itemCollectionView.dragInteractionEnabled = true
        let title = defaults.string(forKey: "title")
        itemArray = [BoardItem]()
        self.title = "\(title!)"
        
        //MENU BUTTON CONFIG
        itemCollectionView.addSubview(menu)
        
        let buttons = [ "NOTE", "CAMERA", "MAP", "WEBPAGE" ]
        
        let items = buttons.map { button -> MenuItem in
            var item = MenuItem(image: UIImage(named: button)!)
            item.backgroundColor = UIColor(displayP3Red: 000, green: 000, blue: 000, alpha: 0.0)
            item.highlightedBackgroundColor = UIColor(displayP3Red: 000, green: 000, blue: 000, alpha: 0.0)
            return item
        }
        //PULL DOWN BUTTON
        pullButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        pullButton.setBackgroundImage(UIImage(named:"blue-add"), for: .normal)
        pullButton.addTarget(self, action: #selector(self.dropMenu), for: UIControlEvents.touchUpInside)
        pullButton.translatesAutoresizingMaskIntoConstraints = false
        self.itemCollectionView.addSubview(pullButton)
        pullButton.center = CGPoint(x: itemCollectionView.frame.size.width  / 2,
                                    y: 20)
        //MENU ITEMS
        menu.items = items
        menu.backgroundColor = UIColor(displayP3Red: 000, green: 000, blue: 000, alpha: 0.0)
        
        
        //LONGPRESS RECOGNIZER
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        itemCollectionView.addGestureRecognizer(longPressGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.deleteItem))
        doubleTap.numberOfTapsRequired = 2
        itemCollectionView.addGestureRecognizer(doubleTap)
        
        //REGISTER CELL XIBS
        itemCollectionView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellWithReuseIdentifier: "noteViewCell")
        itemCollectionView.register(UINib(nibName: "ListCell", bundle: nil), forCellWithReuseIdentifier: "listCell")
        itemCollectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        itemCollectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        itemCollectionView.register(UINib(nibName: "WebpageCell", bundle: nil), forCellWithReuseIdentifier: "webpageCell")
        itemCollectionView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellWithReuseIdentifier: "mapViewCell")
        
        //IMAGE PICKER CONFIG
        config.library.mediaType = .photoAndVideo
        config.screens = [.library, .photo, .video]
        let picker = YPImagePicker(configuration: config)

        //INVOKE FUNCTIONS
        configureCollectionView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.renderItems()
    }
    
////////////////////////////////////////////////////////////////////////////////
////////////////  CONFIGURE COLLECTION VIEW ///////
///////////////////////////////////////////////////////////////////////////////
    //DETERMINE CELL COUNT
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func configureCollectionView() {
        if let flowLayout = itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 175, height: 175)
        }
        func preferredLayoutAttributesFittingAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
                let size = itemCollectionView.systemLayoutSizeFitting(layoutAttributes.size)
                var newFrame = layoutAttributes.frame
                newFrame.size.width = CGFloat(ceilf(Float(size.width)))
                layoutAttributes.frame = newFrame
            return layoutAttributes
        }
    }
    
    //OVERRIDE MEMORY
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
////////////////////////////////////////////////////////////////////////////////
////////////////  RENDER CELLS FROM OBJECTS ARRAY ///////
///////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //NOTE CELL
        if (itemArray[indexPath.row].type == "note") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
            cell.content.text = itemArray[indexPath.row].content
            cell.noteId = itemArray[indexPath.row].id
            let addedBy = itemArray[indexPath.row].addedBy
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/users/\(addedBy).jpg")
            let placeholderImage = UIImage(named: "user-icon")
            cell.userPhoto?.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            cell.userPhoto?.layer.masksToBounds = false
            cell.userPhoto?.layer.cornerRadius = (cell.userPhoto?.frame.height)!/2
            cell.userPhoto?.clipsToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: -10, height: 10)
            cell.layer.shadowRadius = 1
            let imagePath = UIBezierPath(rect: CGRect(x: 7, y: 100 , width: (cell.userPhoto?.frame.width)!, height: (cell.userPhoto?.frame.height)!))
            cell.content.textContainer.exclusionPaths = [imagePath]
            return cell
            //IMAGE CELL
        } else if (itemArray[indexPath.row].type == "image") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
            cell.imageTitle.text = itemArray[indexPath.row].content
            cell.imageId = itemArray[indexPath.row].id
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("\(itemArray[indexPath.row].link)")
            let imageView = cell.img
            let placeholderImage = UIImage(named: "angle-mask.png")
            imageView?.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            let addedBy = itemArray[indexPath.row].addedBy
            let userImageRef = storageRef.child("images/users/\(addedBy).jpg")
            let userPlaceholderImage = UIImage(named: "user-icon")
            cell.userPhoto?.sd_setImage(with: userImageRef, placeholderImage: userPlaceholderImage)
            cell.userPhoto?.layer.masksToBounds = false
            cell.userPhoto?.layer.cornerRadius = (cell.userPhoto?.frame.height)!/2
            cell.userPhoto?.clipsToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: -10, height: 10)
            cell.layer.shadowRadius = 1
            return cell
            //WEBPAGE CELL
        } else if (itemArray[indexPath.row].type == "webpage") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
            cell.webpageId = itemArray[indexPath.row].id
            cell.webpageUrl = itemArray[indexPath.row].url
            
            cell.info.text = itemArray[indexPath.row].content
            let webpageView = cell.img
            let placeholderImage = UIImage(named: "angle-mask.png")
            webpageView?.sd_setImage(with: URL(string: "\(itemArray[indexPath.row].link)"), placeholderImage: placeholderImage)
            self.view.layoutIfNeeded()
            let addedBy = itemArray[indexPath.row].addedBy
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/users/\(addedBy).jpg")
            let userPlaceholderImage = UIImage(named: "user-icon")
            cell.userPhoto?.sd_setImage(with: imageRef, placeholderImage: userPlaceholderImage)
            cell.userPhoto?.layer.masksToBounds = false
            cell.userPhoto?.layer.cornerRadius = (cell.userPhoto?.frame.height)!/2
            cell.userPhoto?.clipsToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.8
            cell.layer.shadowOffset = CGSize(width: -5, height: 5)
            cell.layer.shadowRadius = 1
            return cell
            //MAP CELL
        } else if (itemArray[indexPath.row].type == "map") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapViewCell", for: indexPath) as! MapViewCell
            let lat = itemArray[indexPath.row].link
            let long = itemArray[indexPath.row].url
            let camera = GMSCameraPosition.camera(withLatitude: Double(lat)!, longitude: Double(long)!, zoom: 12.5)
            cell.myMapView.camera = camera
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            marker.snippet = "\(itemArray[indexPath.row].content)"
            marker.map = cell.myMapView
            cell.mapTitle.text = "\(itemArray[indexPath.row].content)"
            cell.locationId = "\(itemArray[indexPath.row].coordinates)"
            let addedBy = itemArray[indexPath.row].addedBy
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/users/\(addedBy).jpg")
            let placeholderImage = UIImage(named: "user-icon")
            cell.userPhoto?.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
            cell.userPhoto?.layer.masksToBounds = false
            cell.userPhoto?.layer.cornerRadius = (cell.userPhoto?.frame.height)!/2
            cell.userPhoto?.clipsToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.8
            cell.layer.shadowOffset = CGSize(width: -5, height: 5)
            cell.layer.shadowRadius = 1
            cell.layer.cornerRadius = 7
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "webpageCell", for: indexPath) as! WebpageCell
        return cell
    }
    
////////////////////////////////////////////////////////////////////////////////
////////////////  RENDER ALL ITEMS FROM POSTGRESQL DB INTO OBJECTS IN ARRAY///////
///////////////////////////////////////////////////////////////////////////////
    func renderItems() {
        SVProgressHUD.dismiss()
//        itemArray.removeAllObjects()
        itemArray = [BoardItem]()
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let url = "https://powerful-earth-36700.herokuapp.com/\(userId!)/\(boardId!)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            if let data : JSON = JSON(response.result.value!) {
                let allItems = data["response"]
                for item in allItems.arrayValue {
                    let boardItem = BoardItem()
                    boardItem.id = item["id"].stringValue
                    boardItem.addedBy = item["added_by"].stringValue
                    boardItem.link = item["link"].stringValue
                    boardItem.content = item["content"].stringValue
                    boardItem.boardId = item["board_id"].stringValue
                    boardItem.url = item["webpage_url"].stringValue
                    boardItem.coordinates = item["location"].stringValue
                    boardItem.type = item["type"].stringValue
                    boardItem.position = item["position"].stringValue
                    self.itemArray.append(boardItem)
                }
            SVProgressHUD.dismiss()
            self.itemCollectionView.reloadData()
        }
    }
    }
    
////////////////////////////////////////////////////////////////////////////////
//////////////// SELECT ITEM AT METHODS ///////
///////////////////////////////////////////////////////////////////////////////
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
            let imageView = cell.img
            let newImageView = UIImageView(image: imageView?.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            newImageView.backgroundColor = UIColor(displayP3Red: 000, green: 000, blue: 000, alpha: 0.8)
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.tabBar.isHidden = true
         //IF MAP
        } else if (cell as? MapViewCell) != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! MapViewCell
//            let locationId = cell.locationId
            let url = URL(string: "https://www.google.com/maps/dir/?api=1&origin=Puyallup+WA&destination=QVB&destination_place_id=\(cell.locationId)")
            UIApplication.shared.open(url!, options: [:])
        }

    }
    //TAPPED AWAY
    @objc func tappedAwayFunction(_ sender: UITapGestureRecognizer) {
        print("tapped away")
        view.willRemoveSubview(subView)
        self.resignFirstResponder()
    }
    
////////////////////////////////////////////////////////////////////////////////
//////////////// DELETE ITEM METHOD ///////
///////////////////////////////////////////////////////////////////////////////
    @objc func deleteItem(_ gesture: UITapGestureRecognizer) {
        let selectedIndexPath = (itemCollectionView.indexPathForItem(at: gesture.location(in: itemCollectionView)))
        let item = self.itemArray[selectedIndexPath![1]]
        let itemId = item.id
        let alert = UIAlertController(title: "Delete this item?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in
            SVProgressHUD.show()
            let url = "https://powerful-earth-36700.herokuapp.com/deleteItem/\(itemId)"
            Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                if let data : JSON = JSON(response.result.value!) {
                    print(data)
                    
                }
                SVProgressHUD.dismiss()
                self.renderItems()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

////////////////////////////////////////////////////////////////////////////////
//////////////// BUTTON METHODS ///////
///////////////////////////////////////////////////////////////////////////////
    //PHOTO BUTTON
    func addImage() {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                SVProgressHUD.show()
                self.uploadImage(photo.image, progressBlock: { (percentage) in
                    print(percentage)
                }, completionBlock: { (fileURL, errorMessage) in
                    print(errorMessage)
                })
                print(photo)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }

    //MAP BUTTON
    func addMap() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        subView.tag = 100
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    //NOTE BUTTON
    func addNote() {
        let url = "https://powerful-earth-36700.herokuapp.com/addItem"
        let userId = defaults.string(forKey: "userId")
        let boardId = defaults.string(forKey: "boardId")
        let params = [
            "itemType": "note",
            "added_by": Int(userId!)!,
            "link": "",
            "content": "",
            "board_id": boardId,
            "position": self.itemArray.count + 1
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }
    //WEBPAGE BUTTON
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
            SVProgressHUD.show()
            self.getWebsiteThumbnail(url: textField.text!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //DISMISS IMAGE BUTTON
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.alpha = 1
        UIView.animate(withDuration: 1.5, animations: {
            sender.view?.alpha = 0
            sender.view?.removeFromSuperview()
        })
    }
    //BACK BUTTON
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    //SETTINGS BUTTON
    @IBAction func settingsButton(_ sender: UIBarButtonItem) {
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "BoardSettingsViewController")
            self.navigationController!.pushViewController(controller!, animated: true)
        }

////////////////////////////////////////////////////////////////////////////////
////////////////  DATABASE CALLS POSTGRESQL DB && FIREBASE AFTER BUTTON CLICK ///////
///////////////////////////////////////////////////////////////////////////////
    //ADD MAP TO POSTGRESQL DB
    func addMapToDB(latitude : String, longitude: String, locationId: String) {
        let viewWithTag = self.view.viewWithTag(100)
        viewWithTag?.removeFromSuperview()
        let alert = UIAlertController(title: "Add location note", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            SVProgressHUD.show()
            guard let textField = alert?.textFields![0] else {
                return
            }
            let content = textField.text
            let url = "https://powerful-earth-36700.herokuapp.com/addItem"
            let userId = self.defaults.string(forKey: "userId")
            let boardId = self.defaults.string(forKey: "boardId")
            let params = [
                "itemType": "map",
                "added_by": Int(userId!)!,
                "link": Double(latitude)!,
                "webpage_url": Double(longitude)!,
                "content": "\(content!)",
                "board_id": Int(boardId!)!,
                "location": String(locationId),
                "position": self.itemArray.count + 1
                
                ] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
                self.renderItems()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> (String, String){
        let location = locations.last
        return("\((location?.coordinate.latitude)!)", "\((location?.coordinate.longitude)!)")
    }
    //ADD IMAGE TO FIREBASE DB
    func uploadImage(_ image: UIImage,  progressBlock: @escaping (_ percentage: Double) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
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
                "content": "title",
                "board_id": "\(boardId!)"
            ]
            metadata.contentType = "image/jpeg"
            let uploadTask = imageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                imageRef.downloadURL(completion: { (url, error) in
                    if let metadata = metadata {
                        self.getCaption(fileName: fileName)
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
    //GET IMAGE CAPTION ALERT
    func getCaption(fileName: String) {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "Add a caption!", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            let content = textField.text!
            self.addImageToDB(filename: fileName, content: content)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    //ADD IMAGE TO POSTGRESSQL DB
    func addImageToDB(filename : String, content : String) {
        let name = filename
        let caption  = content
        let boardId = defaults.string(forKey: "boardId")
        let userId = defaults.string(forKey: "userId")
        let params = [
            "itemType": "image",
            "added_by": Int(userId!)!,
            "link": "images/\(String(describing: boardId!))/\(String(describing: name)).jpg",
            "content": "\(caption)",
            "board_id": Int(boardId!)!,
            "position": self.itemArray.count + 1
            ] as [String : Any]
        let url = "https://powerful-earth-36700.herokuapp.com/addItem"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }
    //GET WEBSITE METADATA FROM SLP API
    func getWebsiteThumbnail(url: String) {
        slp.preview(
            "\(url)",
            onSuccess: { result in
                let imageIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "image")!)
                let image = result[imageIndex!].value
//                let titleIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "title")!)
                let urlIndex = result.index(forKey: SwiftLinkResponseKey(rawValue: "url")!)
                let webpageUrl = result[urlIndex!].value
                self.websiteInfo(image: image as! String, webpageUrl: webpageUrl as! URL)
        },
            onError: { error in
                print("\(error)")
        }
        )
    }
    //WEBSITE TITLE ALERT
    func websiteInfo(image: String, webpageUrl: URL) {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "Add website description", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0] else {
                return
            }
            self.addWebsiteToDatabase(title: textField.text!, image: image, webpageUrl: webpageUrl)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //ADD WEBSITE TO POSTGRESQL DB
    func addWebsiteToDatabase(title: String, image: String, webpageUrl: URL) {
        let url = "https://powerful-earth-36700.herokuapp.com/addItem"
        let userId = self.defaults.string(forKey: "userId")
        let boardId = self.defaults.string(forKey: "boardId")
        let params = [
            "itemType": "webpage",
            "added_by": Int(userId!)!,
            "link": "\(image)",
            "content": "\(title)",
            "board_id": Int(boardId!)!,
            "webpage_url": "\(webpageUrl)",
            "position": self.itemArray.count + 1
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON {_ in
            self.renderItems()
        }
    }

////////////////////////////////////////////////////////////////////////////////
////////////////  MOVE ITEM IN COLLECTION VIEW DELEGATE METHODS ///////
///////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempvalue1 = itemArray[sourceIndexPath.row]
        itemArray.remove(at: sourceIndexPath.row)
        itemArray.insert(tempvalue1, at: destinationIndexPath.row)
//        for item in itemArray {
//            item.position = destinationIndexPath.row.stringValue
//        }
    }

////////////////////////////////////////////////////////////////////////////////
//////////////////// LONGPRESS DRAG & DROP METHODS/////////
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

////////////////////////////////////////////////////////////////////////////////
//////////////// DROP MENU METHODS ///////
///////////////////////////////////////////////////////////////////////////////
    @objc func dropMenu() {
        if menu.revealed == false {
            menu.setRevealed(true, animated: true)
            menu.revealed = true
        } else {
            menu.setRevealed(false, animated: true)
            menu.revealed = false
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//////////////// MENU DELEGATE EXTENSION ///////
///////////////////////////////////////////////////////////////////////////////
extension BoardViewController: MenuViewDelegate {
    func menu(_ menu: MenuView, didSelectItemAt index: Int) {
        menu.revealed = false
        if index == 0 {
            addNote()
        } else if index == 1 {
            addImage()
        } else if index == 2 {
            addMap()
        } else if index == 3 {
            addWebsite()
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//////////////// PLACE PICKER EXTENSION ///////
///////////////////////////////////////////////////////////////////////////////
extension BoardViewController {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        self.addMapToDB(latitude: "\(place.coordinate.latitude)", longitude: "\(place.coordinate.longitude)", locationId: "\(place.placeID)")
    
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}





