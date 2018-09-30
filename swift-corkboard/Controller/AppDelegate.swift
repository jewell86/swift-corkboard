//
//  AppDelegate.swift
//  swift-corkboard
//
//  Created by Jewell Braden on 9/5/18.
//  Copyright © 2018 Jewell White. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var navigationController: UINavigationController?

    //WHEN APP GETS LOADED, BEFORE FIRST VIEWDIDLOAD
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) ->
        Bool {
            
        GMSServices.provideAPIKey("AIzaSyAXb0hDm-Sxe6rkj1dFoJRDhAGDhur2Ue8")
        GMSPlacesClient.provideAPIKey("AIzaSyBDV32OpTULUxmcZRu7s2JDXj18tZZrJ9w")
        GMSServices.provideAPIKey("AIzaSyBDV32OpTULUxmcZRu7s2JDXj18tZZrJ9w")

        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let token: String? = KeychainWrapper.standard.string(forKey: "token")
        if token != nil
        {
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homePage = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//            self.window?.rootViewController = homePage
        }
//        GMSPlacesClient.provideAPIKey("AIzaSyC4vIrCJoMEiydy21Sy968-STfTWG0J3fI")
        
        return true
    }
    
    //WHEN SOMETHING HAPPENS WHILE APP IS OPEN IE GETTING PHONE CALL
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    //WHEN APP IS NO LONGER ON MAIN SCREEN
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    //USER OR SYSTEM TRIGGERED - WHEN USER CLOSES APP OR IF ANOTHER APP TAKES OVER SPACE AND TERMINATES APP
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

