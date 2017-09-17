//
//  Constants.swift
//  VisualTwitter
//
//  Created by Steve Kerney on 9/17/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import Foundation
import OAuthSwift



//OAuth1.1
let oauthswift = OAuth1Swift(
    consumerKey:    Consumer_API_KEY,
    consumerSecret: Consumer_API_SECRET,
    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
    accessTokenUrl:  "https://api.twitter.com/oauth/access_token");
let OAuthCallBackURL: URL = URL(string: "VisualTwitter://loginSuccess")!;

//Twitter API Keys
let Consumer_API_KEY = "*";
let Consumer_API_SECRET = "*";
