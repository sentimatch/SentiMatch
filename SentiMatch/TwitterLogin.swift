//
//  ViewController.swift
//  AngelhackTest
//
//  Created by Jay Ravaliya on 6/6/15.
//  Copyright (c) 2015 JRav. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterLogin: UIViewController {
    
    var sessionStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            // Swift
            Twitter.sharedInstance().logInWithCompletion {
                (session, error) -> Void in
                if (session != nil) {
                    
                    println("signed in as \(session.userName)");
                    println("user id as \(session.userID)")
                    println("auth token as \(session.authToken)")
                    println("auth token secret as \(session.authTokenSecret)")
                    
                    self.sessionStr = String(session.userID)
                    
                } else {
                    
                    println("error: \(error.localizedDescription)");
                }
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonPressed(sender: AnyObject) {
        
        if(Twitter.sharedInstance().session() != nil)
        {
            if let shareEmailViewController = TWTRShareEmailViewController(completion: {
                (email: String!, error: NSError!) in
                if (email != nil) {
                    print("\(email)")
                } else {
                    print("\(error)")
                }
            }) {
                self.presentViewController(shareEmailViewController, animated: true, completion: nil)
            }
        }
        else
        {
            println("NOT SIGNED IN DUDE")
        }
        
        if (Twitter.sharedInstance().session() != nil)
        {
            Twitter.sharedInstance().APIClient.loadUserWithID(sessionStr, completion: { (user, error) -> Void in
                    if(user != nil)
                    {
                        println(user.profileImageMiniURL)
                }
            })
        }
    }
    
    @IBAction func secondButtonPressed(sender: AnyObject)
    {
        // Swift
        let tweetIDs = ["20", "510908133917487104"]
        Twitter.sharedInstance().APIClient.loadTweetsWithIDs(tweetIDs) {
            (tweets, error) -> Void in
            if (error == nil)
            {
                println(tweets)
            }
            else
            {
                println(error)
            }
        }
    }
    
    
    
    
    
}


