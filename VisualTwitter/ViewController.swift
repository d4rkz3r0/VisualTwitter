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
import Kingfisher

class ViewController: NSViewController
{
    //MARK: IBOutlets
    @IBOutlet weak var loginLogoutButton: NSButton!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var reloadButton: NSButton!
    
    //Tweet Image URLs
    var imageURLS: [URL] = [];
    var tweetURLS: [URL] = [];
    
    //Refresh
    var timer: Timer?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        initUI();
        
        if userHasSavedTokens()
        {
            loginLogoutButton.title = "Log Out";
            getUserTokens();
            getTimelineTweetImages();
        }
    }
    
    //MARK: IBActions
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
    
    @IBAction func reloadTimelineButtonClicked(_ sender: Any)
    {
        guard userHasSavedTokens(), (timer?.isValid)! else { print("not logged in or timer is not init"); return; }
        clearUI();
        getTimelineTweetImages();
        reloadButton.isEnabled = false;
    }
}

//MARK: Collection View
extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource
{
    fileprivate func initUI()
    {
        let collectionViewFlowLayout = NSCollectionViewFlowLayout();
        collectionViewFlowLayout.itemSize = itemSize;
        collectionViewFlowLayout.sectionInset = itemBorderSpacing;
        collectionViewFlowLayout.minimumLineSpacing = minItemRowSpacing;
        collectionViewFlowLayout.minimumInteritemSpacing = minInterItemSpacing;
        collectionView.collectionViewLayout = collectionViewFlowLayout;
    }
    
    fileprivate func clearUI()
    {
        imageURLS.removeAll(keepingCapacity: true);
        tweetURLS.removeAll(keepingCapacity: true);
        collectionView.reloadData();
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imageURLS.count;
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        guard let vVisualTweetItem = collectionView.makeItem(withIdentifier: visualTweetItemIdentifier, for: indexPath) as? VisualTweetItem else { fatalError("Could not find a class/xib with the name: \(visualTweetItemIdentifier)"); }
        
        vVisualTweetItem.imageView?.kf.setImage(with: imageURLS[indexPath.item]);
        return vVisualTweetItem;
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        collectionView.deselectAll(nil);
        
        guard let vSelectedTweetIndex = indexPaths.first?.item else { return; }
        NSWorkspace.shared().open(tweetURLS[vSelectedTweetIndex]);
    }
}

//MARK: Twitter API Calls
extension ViewController
{
    fileprivate func twitterLogin()
    {
        oauthswift.authorize( withCallbackURL: OAuthCallBackURL, success: { credential, response, parameters in
            
            self.saveUserTokens(userCredential: credential);
            self.getTimelineTweetImages();
            
        }, failure: { error in print(error.localizedDescription); });
    }
    
    fileprivate func twitterLogout()
    {
        disableTimer();
        eraseUserTokens();
        clearUI();
    }
    
    fileprivate func getTimelineTweetImages()
    {
        initTimer();
        
        let _ = oauthswift.client.get(Timeline_API_ENDPOINT, parameters: ["tweet_mode":"extended", "count":Tweet_FETCH_COUNT], success: { response in
            
            let json = JSON(data: response.data);
            
            //Tweet Parsing
            for (_, tweetJSON):(String, JSON) in json
            {
                //ReTweet Tracking
                var isAnRT = false;
                
                //ReTweets
                for (_, mediaJSON):(String, JSON) in tweetJSON["retweeted_status"]["extended_entities"]["media"]
                {
                    isAnRT = true;
                    
                    if let vRTImageURL = URL(string: mediaJSON["media_url_https"].stringValue)
                    {
                        self.imageURLS.append(vRTImageURL);
                    }
                    if let vRTweetURL = URL(string: mediaJSON["expanded_url"].stringValue)
                    {
                        self.tweetURLS.append(vRTweetURL);
                    }
                }
                
                //Regular Tweets
                if !isAnRT
                {
                    for (_, mediaJSON):(String, JSON) in tweetJSON["extended_entities"]["media"]
                    {
                        if let vImageURL = URL(string: mediaJSON["media_url_https"].stringValue)
                        {
                            self.imageURLS.append(vImageURL);
                        }
                        if let vTweetURL = URL(string: mediaJSON["expanded_url"].stringValue)
                        {
                            self.tweetURLS.append(vTweetURL);
                        }
                    }
                }
            }
            
            self.collectionView.reloadData();
            
        }, failure: { error in print(error.localizedDescription); });
    }
}

//MARK: Helper Funcs
extension ViewController
{
    fileprivate func userHasSavedTokens() -> Bool
    {
        guard UserDefaults.standard.string(forKey: UserDefaults_UserTokenKey) != nil, UserDefaults.standard.string(forKey: UserDefaults_UserTokenSecretKey) != nil else { return false; }
        return true;
    }
    
    fileprivate func getUserTokens()
    {
        guard let vOAuthToken = UserDefaults.standard.string(forKey: UserDefaults_UserTokenKey), let vOAuthTokenSecret = UserDefaults.standard.string(forKey: UserDefaults_UserTokenSecretKey) else { return; }
        oauthswift.client.credential.oauthToken = vOAuthToken;
        oauthswift.client.credential.oauthTokenSecret = vOAuthTokenSecret;
    }
    
    fileprivate func saveUserTokens(userCredential: OAuthSwiftCredential)
    {
        loginLogoutButton.title = "Log Out";
        UserDefaults.standard.set(userCredential.oauthToken, forKey: UserDefaults_UserTokenKey);
        UserDefaults.standard.set(userCredential.oauthTokenSecret, forKey: UserDefaults_UserTokenSecretKey);
        UserDefaults.standard.synchronize();
    }
    
    fileprivate func eraseUserTokens()
    {
        loginLogoutButton.title = "Log In";
        UserDefaults.standard.removeObject(forKey: UserDefaults_UserTokenKey);
        UserDefaults.standard.removeObject(forKey: UserDefaults_UserTokenSecretKey);
        UserDefaults.standard.synchronize();
    }
    
    fileprivate func initTimer()
    {
        timer = Timer.scheduledTimer(withTimeInterval: Timeline_REFRESH_INTERVAL, repeats: true, block: { (timer) in
            self.reloadButton.isEnabled = true;
        });
    }
    
    fileprivate func disableTimer()
    {
        if (timer?.isValid)!
        {
            timer!.invalidate();
        }
    }
}
