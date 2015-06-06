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

    func buttonAction(sender:UIButton!)
    {
        getUserTweets(sessionStr, completion: { (result) -> Void in
            println(result)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.frame = CGRectMake(100, 100, 100, 50)
            button.backgroundColor = UIColor.greenColor()
            button.setTitle("Test Button", forState: UIControlState.Normal)
            button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.view.addSubview(button)

        
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

    func getUserTweets(user_id : String, completion: (result: AnyObject?) -> Void)
    {
        // Swift
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["user_id": user_id]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params,error: &clientError)
        
        if request != nil
        {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    var jsonError : NSError?
                    let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
                    completion(result: json)
                }
                else {
                    println("Error: \(connectionError)")
                    
                }
            }
        }
        else {
            println("Error: \(clientError)")
        }
        
        
    }
    
    @IBAction func secondButtonPressed(sender: AnyObject)
    {
        
        // Swift
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["user_id": sessionStr]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
                "GET", URL: statusesShowEndpoint, parameters: params,
                error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                    (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        var jsonError : NSError?
                        let json : AnyObject? =
                        NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError)
                        println(json)
                    }
                    else {
                        println("Error: \(connectionError)")
                    }
            }
        }
        else {
            println("Error: \(clientError)")
        }
        
        /*// Swift
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = []
        var clientError : NSError?
        
        let urlRequest = NSURLRequest(URL: NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=\(sessionStr)")!)
        
        let myRequest = Twitter.sharedInstance().APIClient.sendTwitterRequest(urlRequest, completion: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if(error == nil)
                {
                    println(data)
                }
                else
                {
                    println(error)
                }
        })
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                    (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        var jsonError : NSError?
                        let json : AnyObject? =
                        NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError)
                        println(json)
                    }
                    else {
                        println("Error: \(connectionError)")
                    }
            }
        }
        else {
            println("Error: \(clientError)")
        }*/
        
    }

    
}


