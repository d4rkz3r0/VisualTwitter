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
    //MARK: IBOutlets
    @IBOutlet weak var loginLogoutButton: NSButton!

    //User
    let userToken: String? = nil;
    let userTokenSecret: String? = nil;
    var isUserLoggedIn = false;
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        if userHasSavedTokens()
        {
            loginLogoutButton.title = "Log Out";
            getUserTokens();
            getTimelineTweetImages();
        }
    }
}

//MARK: IBActions
extension ViewController
{
    @IBAction func loginLogoutButtonClicked(_ sender: Any)
    {
        if loginLogoutButton.title == "Log In" && !userHasSavedTokens()
        {
            twitterLogin();
        }
        else
        {
            twitterLogout();
        }
    }
}

//MARK: Helper Funcs
extension ViewController
{
    func userHasSavedTokens() -> Bool
    {
        guard UserDefaults.standard.string(forKey: "userToken") != nil, UserDefaults.standard.string(forKey: "userTokenSecret") != nil else { return false; }
        return true;
    }
    
    func saveUserTokens(userCredential: OAuthSwiftCredential)
    {
        loginLogoutButton.title = "Log Out";
        UserDefaults.standard.set(userCredential.oauthToken, forKey: "userToken");
        UserDefaults.standard.set(userCredential.oauthTokenSecret, forKey: "userTokenSecret");
        UserDefaults.standard.synchronize();
    }
    
    func getUserTokens()
    {
        guard let vOAuthToken = UserDefaults.standard.string(forKey: "userToken"), let vOAuthTokenSecret = UserDefaults.standard.string(forKey: "userTokenSecret") else { return; }
        oauthswift.client.credential.oauthToken = vOAuthToken;
        oauthswift.client.credential.oauthTokenSecret = vOAuthTokenSecret;
    }
    
    func eraseUserTokens()
    {
        loginLogoutButton.title = "Log In";
        UserDefaults.standard.removeObject(forKey: "userToken");
        UserDefaults.standard.removeObject(forKey: "userTokenSecret");
        UserDefaults.standard.synchronize();
    }
    

}

//MARK: Twitter API Calls
extension ViewController
{
    func twitterLogin()
    {
        oauthswift.authorize( withCallbackURL: OAuthCallBackURL, success: { credential, response, parameters in
            
            self.saveUserTokens(userCredential: credential);
            self.getTimelineTweetImages();
            
        }, failure: { error in print(error.localizedDescription); });
    }
    
    func twitterLogout()
    {
        eraseUserTokens();
    }
    
    func getTimelineTweetImages()
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
