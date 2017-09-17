//
//  AppDelegate.swift
//  VisualTwitter
//
//  Created by Steve Kerney on 9/17/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import Cocoa
import OAuthSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        //Register to respond to kAEGetURL event.
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURL(event:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL));
    }
    
    func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!)
    {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) else { return; }
        OAuthSwift.handle(url: url)
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        
    }
}
