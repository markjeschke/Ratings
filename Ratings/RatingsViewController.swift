//
//  RatingsViewController.swift
//  Ratings
//
//  Created by Mark Jeschke on 8/17/16.
//  Copyright © 2016 Mark Jeschke. All rights reserved.
//

import Foundation
import UIKit

class RatingsViewController: UITableViewController {
    
    // MARK: === Variables and Constants ===
    
    // Enter your app's track/Apple ID from iTunes. This cannot be empty in order for the iTunes app look up search to work.
    var trackId:String = "589674071"
    
    // Create empty strings that will hold the iTunes API data
    var trackName: String?
    var userRatingCountForCurrentVersion: Int?
    var userRatingCountMessage: String?
    var averageUserRatingForCurrentVersion: Double?
    var averageUserRatingForCurrentVersionStars: String?
    var averageUserRating: Double?
    var averageUserRatingStars: String?
    var version: String?
    var formattedPrice: String?
    var artworkUrl512: String?
    
    // Enter your app's provider token:
    var providerToken:String? = "259432"
    
    // Enter your Apple affiliate token:
    var affiliateToken:String? = "10l3KX"

    // Enter your campaign token:
    var campaignToken:String? = "ratings-drumkick"

    // Product link on the App Store (AKA: 'trackViewUrl')
    var appStoreProductLink:String?
    
    // Message for your users
    var ratingsInterruptionMessage:String = ""
    
    // Review and rating link on the App Store
    var appStoreReviewLink:String? = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
    
    // Create an empty array to hold the jsonResults from the ApiManager
    var jsonResults = [[String: AnyObject]]() // json results array
    var resultsDict = [:] // dictionary to parse the properies within the json results
    
    // Timer to check whether a network connection is enabled
    var networkDetectionTimer: NSTimer?
    let timerInterval:Double = 1.0
    var elapsedSeconds:Int = 0
    let timeout:Int = 60
    
    // Create an accessoryView and activity indicator
    let appPurchaseBtn = UIButton(frame: CGRectMake(0.0, 0.0, 80.0, 20.0))
    let accessoryViewIcon = UILabel(frame: CGRectMake(0.0, 0.0, 20.0, 20.0))
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    // Set fonts
    let fontBold = "KohinoorDevanagari-Semibold"
    let fontRegular = "KohinoorDevanagari-Regular"
    
    let starRating = StarRating()
    let userRatingCount = UserRatingCount()
    
    let blueColor = UIColor(red: 13/255, green: 160/255, blue: 255/255, alpha: 1)
    
    // MARK: === View Life-cycle ===
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the JSON request.
        requestData(trackId)
        
        title = "Loading info..."
        
        // Add a notification listener for when the API content has been received successfully.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: "refreshContent", object: nil)
        
        // Add a notification listener to trigger alerts with custom error messaging.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(alertNotification), name: "alertController", object: nil)
        
        // Add UIActivityIndicator to the navigation bar.
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setLeftBarButtonItem(barButton, animated: true)
        activityIndicator.color = UIColor.darkGrayColor()
        activityIndicator.hidesWhenStopped = true
        
        // Set the attributes for accessory view icon in the 'Rate & Review in the App Store' TableView cell.
        accessoryViewIcon.textColor = UIColor.darkGrayColor()
        accessoryViewIcon.font = UIFont(name: "FontAwesome", size: 16)
        // The accessory view displays an external link icon from the FontAwesome font.
        // The unicode numbers for each icon can be found here: http://fontawesome.io/cheatsheet/
        accessoryViewIcon.text = "\u{f08e}"
    }
    
    // MARK: === Request, Save, & Parse JSON Data ===
    
    func requestData(trackId:String) {
        ApiManager.sharedInstance.getApiRequest(trackId)
        startActivityAnimation()
    }
    
    // This method gets called when the JSON is received successfully.
    func dataReceived() {
        jsonResults = ApiManager.sharedInstance.jsonResults
        parseResultsData()
        stopActivityAnimation()
    }
    
    func parseResultsData() {
        
        for count in 0 ..< jsonResults.count {
            resultsDict = jsonResults[count] as NSDictionary
            trackName = resultsDict["trackName"] as? String
            averageUserRatingForCurrentVersion = resultsDict["averageUserRatingForCurrentVersion"] as? Double
            averageUserRating = resultsDict["averageUserRating"] as? Double
            userRatingCountForCurrentVersion = resultsDict["userRatingCountForCurrentVersion"] as? Int
            version = resultsDict["version"] as? String
            formattedPrice = resultsDict["formattedPrice"] as? String
            appStoreProductLink = resultsDict["trackViewUrl"] as? String
            artworkUrl512 = resultsDict["artworkUrl512"] as? String
        }
        
        title = "App Information"
        
        // Using FontAwesome star icons, the amount displayed are determind by the received double value
        // The unicode numbers for each icon can be found here: http://fontawesome.io/cheatsheet/
 
        averageUserRatingForCurrentVersionStars = starRating.populateStars(averageUserRatingForCurrentVersion!)
        averageUserRatingStars = starRating.populateStars(averageUserRating!)
        
        userRatingCountMessage = userRatingCount.showUserCountMessage(userRatingCountForCurrentVersion!)
        
        // Append the app's trackId to the appStoreReviewLink URL
        appStoreReviewLink! += "&id=\(trackId)"
        
        ratingsInterruptionMessage = "You will never be interrupted for ratings"
        
        productTokenDetection()
        affiliateTokenDetection()
        campaignTokenDetection()
        
        showContent()
        
    }
    
    // MARK: === Product Token Information ===
    
    func productTokenDetection() {
        // Optional binding
        if let providerToken = providerToken {
            appStoreReviewLink! += "&pt=\(providerToken)"
            appStoreProductLink! += "&pt=\(providerToken)"
        }
    }
    
    // MARK: === Affiliate Token Information ===
    
    func affiliateTokenDetection() {
        // Optional binding
        if let affiliateToken = affiliateToken {
            appStoreReviewLink! += "&at=\(affiliateToken)"
            appStoreProductLink! += "&at=\(affiliateToken)"
        }
    }
    
    // MARK: === Campaign Token Information ===
    
    func campaignTokenDetection() {
        // Optional binding
        if let campaignToken = campaignToken {
            appStoreReviewLink! += "&ct=\(campaignToken)"
            appStoreProductLink! += "&ct=\(campaignToken)"
        }
    }
    
    // MARK: === Show App Icon and Purchase Button ===
    
    func showContent() {
        
        // Create the left-side navigation button
        var iconBtn: UIButton = UIButton()
        iconBtn.frame = CGRectMake(0, 0, 30, 30)
        iconBtn.layer.cornerRadius = 8
        iconBtn.layer.masksToBounds = true
        iconBtn.layer.borderWidth = 0.5
        iconBtn.layer.borderColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0).CGColor
        iconBtn.showsTouchWhenHighlighted = true
        //iconBtn.addTarget(self, action: #selector(showIconView), forControlEvents: .TouchUpInside)
        navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: iconBtn), animated: true)
        
        // Load the app icon image into the UIButton
        let imgURL: NSURL = NSURL(string: artworkUrl512!)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if (error == nil && data != nil) {
                func display_image() {
                    iconBtn.setImage(UIImage(data: data!), forState: .Normal)
                    self.tableViewTransition()
                }
                dispatch_async(dispatch_get_main_queue(), display_image)
            }
        }
        task.resume()
        
        // Add purchase button in the right-side navigation
        let appPurchaseBtn:UIButton = UIButton()
        appPurchaseBtn.frame = CGRectMake(0, 0, 55, 25)
        appPurchaseBtn.setTitle("\(formattedPrice!)", forState: .Normal)
        appPurchaseBtn.titleLabel?.textColor = blueColor
        appPurchaseBtn.titleLabel?.font = UIFont(name: fontBold, size: 12)
        appPurchaseBtn.tintColor = blueColor
        appPurchaseBtn.showsTouchWhenHighlighted = true
        appPurchaseBtn.layer.cornerRadius = 5
        appPurchaseBtn.layer.backgroundColor = blueColor.CGColor
        appPurchaseBtn.layer.masksToBounds = true
        appPurchaseBtn.layer.borderWidth = 1.0
        appPurchaseBtn.layer.borderColor = blueColor.CGColor
        appPurchaseBtn.addTarget(self, action: #selector(goToAppStore), forControlEvents: .TouchUpInside)
        navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: appPurchaseBtn), animated: true)
 
    }
    
    // MARK: === Table View Source ===
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.font = UIFont(name: fontBold, size: 14)
        cell.detailTextLabel?.font = UIFont(name: fontRegular, size: 13)
        
        switch (indexPath.row) {
            case 0:
                cell.selectionStyle = .None
                if let trackName = trackName {
                    cell.textLabel!.text = "\(trackName)"
                } else {
                    cell.textLabel!.text = nil
                }
                if let version = version {
                    cell.detailTextLabel!.text = "version \(version)"
                } else {
                    cell.detailTextLabel!.text = nil
                }
            case 1:
                cell.selectionStyle = .None
                cell.accessoryType = .None
                let textMessage = "Average user rating"
                if let averageUserRating = averageUserRating {
                    cell.textLabel!.text = "\(textMessage): \(averageUserRating)"
                    cell.detailTextLabel!.font = UIFont(name: "FontAwesome", size: 12)
                    cell.detailTextLabel?.textColor = UIColor(red: 255/255, green: 195/255, blue: 0/255, alpha: 1.0)
                    cell.detailTextLabel!.text = "\(averageUserRatingStars!)"
                } else {
                    cell.textLabel!.text = nil
                    cell.detailTextLabel!.text = nil
                }
            case 2:
                cell.selectionStyle = .None
                cell.accessoryType = .None
                cell.textLabel!.text = "Average user rating for current version"
                let textMessage = "Average user rating for current version"
                if let averageUserRatingForCurrentVersion = averageUserRatingForCurrentVersion {
                    cell.textLabel!.text = "\(textMessage): \(averageUserRatingForCurrentVersion)"
                    cell.detailTextLabel!.font = UIFont(name: "FontAwesome", size: 12)
                    cell.detailTextLabel?.textColor = UIColor(red: 255/255, green: 195/255, blue: 0/255, alpha: 1.0)
                    cell.detailTextLabel!.text = "\(averageUserRatingForCurrentVersionStars!)"
                } else {
                    cell.textLabel!.text = nil
                    cell.detailTextLabel!.text = nil
                }
            case 3:
                cell.selectionStyle = .None
                cell.accessoryType = .None
                if let userRatingCountForCurrentVersion = userRatingCountForCurrentVersion {
                    cell.textLabel!.text = "User rating count for current version"
                    cell.detailTextLabel!.text = "\(userRatingCountForCurrentVersion)"
                } else {
                    cell.textLabel!.text = nil
                    cell.detailTextLabel!.text = nil
                }
            case 4:
                if let userRatingCountMessage = userRatingCountMessage {
                    cell.selectionStyle = .Default
                    cell.accessoryView = accessoryViewIcon
                    cell.textLabel!.text = "Rate & Review in the App Store"
                    cell.detailTextLabel!.text = userRatingCountMessage
                } else {
                    cell.textLabel!.text = nil
                    cell.detailTextLabel!.text = nil
                }
            default: ()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch(indexPath.row) {
        case 4:
            UIApplication.sharedApplication() .openURL(NSURL (string: appStoreReviewLink!)!)
        default: ()
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footerTitles = [ratingsInterruptionMessage]
        if let footerArray = footerTitles as [String]?
        {
            return footerArray[section]
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let version = UILabel(frame: CGRectMake(0, 10, tableView.frame.width, 15))
        version.font = UIFont(name: fontRegular, size: 13)
        version.textColor = UIColor.darkGrayColor()
        version.text = self.tableView(tableView, titleForFooterInSection: section)
        version.textAlignment = .Center;
        version.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin,  UIViewAutoresizing.FlexibleRightMargin]
        view.addSubview(version)
        return view
    }
    
    func tableViewTransition(duration: NSTimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        
        // Create a CATransition animation
        let tableViewTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            tableViewTransition.delegate = delegate
        }
        
        tableViewTransition.type = kCATransitionFade
        tableViewTransition.duration = duration
        tableViewTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        tableViewTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        tableView.layer.addAnimation(tableViewTransition, forKey: "tableViewTransition")
        tableView.reloadData()
    }
    
    func goToAppStore() {
        UIApplication.sharedApplication() .openURL(NSURL (string: appStoreProductLink!)!)
    }
    
    // MARK: === Activity Indicator Controller ===
    
    func startActivityAnimation() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityAnimation() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: === Network Not Connected Alert ===
    
    func alertNotification(notification: NSNotification) {
        let errorMessage:String = (notification.userInfo!["error"] as? String)!
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            self.beginCheckingNetworkTimer()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func beginCheckingNetworkTimer() {
        print("jsonResults.count from timer: \(jsonResults.count)")
        if jsonResults.count == 0 {
            elapsedSeconds = 0
            print("Started checking the network")
            networkDetectionTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target:self, selector: #selector(checkNetworkConnection), userInfo: nil, repeats: true)
        }
    }
    
    func checkNetworkConnection() {
        // If network connection is found, clear the network timer.
        print("checkNetworkConnection is triggered")
        if jsonResults.count != 0 {
            networkTimerTimeout()
            ApiManager.sharedInstance.networkChecked = false
        } else {
            if elapsedSeconds < timeout {
                title = "Checking network connection..."
                requestData(trackId)
                elapsedSeconds += 1
                print("elapsedSeconds: \(elapsedSeconds)")
            } else {
                title = "Can't connect to the network"
                networkTimerTimeout()
                ApiManager.sharedInstance.networkChecked = false
            }
        }
    }
    
    func networkTimerTimeout() {
        elapsedSeconds = 0
        networkDetectionTimer?.invalidate()
        networkDetectionTimer = nil
        stopActivityAnimation()
        print("NetworkTimer has stopped")
    }

}

struct StarRating {
    func populateStars(ratingCount:Double) -> String {
        switch(ratingCount) {
        case 1:
            return "\u{f005}"
        case 1.5:
            return "\u{f005}\u{f089}"
        case 2:
            return "\u{f005}\u{f005}"
        case 2.5:
            return "\u{f005}\u{f005}\u{f089}"
        case 3:
            return "\u{f005}\u{f005}\u{f005}"
        case 3.5:
            return "\u{f005}\u{f005}\u{f005}\u{f089}"
        case 4:
            return "\u{f005}\u{f005}\u{f005}\u{f005}"
        case 4.5:
            return "\u{f005}\u{f005}\u{f005}\u{f005}\u{f089}"
        case 5:
            return "\u{f005}\u{f005}\u{f005}\u{f005}\u{f005}"
        default:
            return ""
        }
    }
}

struct UserRatingCount {
    func showUserCountMessage(userCount:Int) -> String {
        var howManyUsers:String
        switch(userCount) {
        case 0:
            howManyUsers = "No one has"
        case 1:
            howManyUsers = "\(userCount) person has"
        default:
            howManyUsers = "\(userCount) people have"
        }
        return "\(howManyUsers) rated this current version"
    }
}
