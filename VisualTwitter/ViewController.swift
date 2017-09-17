//
//  ViewController.swift
//  VisualTwitter
//
//  Created by Steve Kerney on 9/17/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import Cocoa
import OAuthSwift
import SwiftyJSON

class ViewController: NSViewController
{
    //OAuth1.0 Authentication
    let oauthswift = OAuth1Swift(
        consumerKey:    Consumer_API_KEY,
        consumerSecret: Consumer_API_SECRET,
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token");

    override func viewDidLoad()
    {
        super.viewDidLoad();
        getUserAccessTokens();
    }

    func getUserAccessTokens()
    {
        oauthswift.authorize( withCallbackURL: OAuthCallBackURL, success: { credential, response, parameters in
            
            //print(credential.oauthToken)
            //print(credential.oauthTokenSecret)
            self.getUserTimelineTweets();
            
        }, failure: { error in print(error.localizedDescription); });
    }
    
    func getUserFollowers()
    {
        let _ = oauthswift.client.get("https://api.twitter.com/1.1/favorites/list.json", success: { response in
            guard let vDataString = response.string else { return; }
            print(vDataString);
            
        }, failure: { error in print(error.localizedDescription); });
    }
    
    func getUserTimelineTweets()
    {
        let _ = oauthswift.client.get("https://api.twitter.com/1.1/statuses/home_timeline.json", parameters: ["tweet_mode":"extended"], success: { response in
            //guard let vDataString = response.string else { return; }
            //print(vDataString);
            
            var imageURLS: [URL] = [];
            
            let json = JSON(data: response.data);
            for (_, tweetJSON):(String, JSON) in json
            {
                for (_, mediaJSON):(String, JSON) in tweetJSON["entities"]["media"]
                {
                    if let vImageURL = URL(string: mediaJSON["media_url_https"].stringValue)
                    {
                        imageURLS.append(vImageURL);
                    }
                }
            }
            print(imageURLS);
            
            
        }, failure: { error in print(error.localizedDescription); });
    }
}
