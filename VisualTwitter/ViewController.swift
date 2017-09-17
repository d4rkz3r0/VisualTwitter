//
//  ViewController.swift
//  VisualTwitter
//
//  Created by Steve Kerney on 9/17/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import Cocoa
import OAuthSwift

class ViewController: NSViewController
{
    //OAuth1.0 Authentication
    let oauthswift = OAuth1Swift(
        consumerKey:    Consumer_API_KEY,
        consumerSecret: Consumer_API_SECRET,
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token")

    override func viewDidLoad()
    {
        super.viewDidLoad();
        getUserAccessTokens();
    }

    func getUserAccessTokens()
    {
        oauthswift.authorize( withCallbackURL: OAuthCallBackURL, success: { credential, response, parameters in
            
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                print(parameters["user_id"]!)
        }, failure: { error in print(error.localizedDescription); });
    }
}
