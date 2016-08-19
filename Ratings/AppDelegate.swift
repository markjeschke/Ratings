//
//  AppDelegate.swift
//  Ratings
//
//  Created by Mark Jeschke on 8/17/16.
//  Copyright © 2016 Mark Jeschke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let ratingsViewController = RatingsViewController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        return true
    }
    
    func customizeAppearance() {
        
        let navTitleAttributes = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "KohinoorDevanagari-Semibold", size: 16)!
        ]
       
        UINavigationBar.appearance().titleTextAttributes = navTitleAttributes
    }

    func applicationDidEnterBackground(application: UIApplication) {
        if (ApiManager.sharedInstance.networkChecked) {
            self.ratingsViewController.networkTimerTimeout()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        if (ApiManager.sharedInstance.networkChecked) {
            self.ratingsViewController.networkTimerTimeout()
        }
    }
}

