//
//  Constants.swift
//  VisualTwitter
//
//  Created by Steve Kerney on 9/17/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import Foundation
import OAuthSwift

//CocoaTouch
let itemSize = NSSize(width: 375, height: 375);
let itemBorderSpacing = EdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0);
let minItemRowSpacing = CGFloat(20.0);
let minInterItemSpacing = CGFloat(10.0);
let visualTweetItemIdentifier = "VisualTweetItem"


//OAuth1.1
let oauthswift = OAuth1Swift(
    consumerKey:    Consumer_API_KEY,
    consumerSecret: Consumer_API_SECRET,
    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
    accessTokenUrl:  "https://api.twitter.com/oauth/access_token");
let OAuthCallBackURL: URL = URL(string: "VisualTwitter://loginSuccess")!;

//Twitter API
let Consumer_API_KEY = "*";
let Consumer_API_SECRET = "*";
let Timeline_API_ENDPOINT = "https://api.twitter.com/1.1/statuses/home_timeline.json";

//UserDefaults
let UserDefaults_UserTokenKey = "userToken";
let UserDefaults_UserTokenSecretKey = "userTokenSecret"
