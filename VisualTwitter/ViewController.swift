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

    //Tweet Image URLs
    var imageURLS: [URL] = [];
    var tweetURLS: [URL] = [];
    
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
        eraseUserTokens();
    }
    
    fileprivate func getTimelineTweetImages()
    {
        let _ = oauthswift.client.get(Timeline_API_ENDPOINT, parameters: ["tweet_mode":"extended", "count":200], success: { response in

            let json = JSON(data: response.data);
            for (_, tweetJSON):(String, JSON) in json
            {
                for (_, mediaJSON):(String, JSON) in tweetJSON["entities"]["media"]
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
}
