//
//  AppDelegate.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-15.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//
// modified by shiww,2016.02.25

import UIKit
import CoreBluetooth


public extension UIDevice {
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    //added by shiww,设置启动引导界面
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            // Override point for customization after application launch.
            NSThread.sleepForTimeInterval(1.0);
            
            #if RELEASE
                //判断是否是ipad pro,并且连接了apple pencil
                //1.is iPad Pro?
                
                if UIDevice.modelName != "iPad Pro"
                {
                    self.showAlertAppDelegate("Alert",message: "Sorry!the App supports iPad Pro  only!",buttonTitle: "ok",window: self.window!);
                    return false;
                    
                }
                //2. connect Apple Pencil?
                let cbCentralMgr=CBCentralManager();
                let exDevices=cbCentralMgr.retrieveConnectedPeripheralsWithServices([CBUUID(string: "180A")]);
                
                //            print(exDevices.count);
                
                var hasPencil=false;
                
                for exDevice in exDevices
                {
                    if exDevice.name=="Apple Pencil"
                    {
                        hasPencil=true;
                    }
                    
                }
                
                if !hasPencil
                {
                    self.showAlertAppDelegate("Alert",message: "Soory,the App  supports Apple Pencil only!",buttonTitle: "ok",window: self.window!);
                    return false;
                }
                
            #endif
            
            
            // 得到当前应用的版本号
            let infoDictionary = NSBundle.mainBundle().infoDictionary
            let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
            
            // 取出之前保存的版本号
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let appVersion = userDefaults.stringForKey("appVersion")
            
            
            // 如果 appVersion 为 nil 说明是第一次启动，显示三个引导页；如果 appVersion 不等于 currentAppVersion 说明是更新了，显示一张引导页
            let guideViewController = GuideViewController();
            
            //            print(self.window?.screen.scale);
            //            print(self.window?.screen.bounds);
            
            if appVersion == nil || appVersion != currentAppVersion {
                // 保存最新的版本号
                userDefaults.setValue(currentAppVersion, forKey: "appVersion")
                guideViewController.numOfPages=3;
                
            }
            else
            {
                guideViewController.numOfPages=1;
                
            }
            self.window?.rootViewController = guideViewController;
            
            return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //在程序启动时弹出消息库
    private func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        // Override point for customization after application launch.
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title:buttonTitle, style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            exit(0);
        }
        
        alert.addAction(okAction);
        
        let controller=UIViewController();
        
        self.window!.rootViewController=controller;
        
        //  self.window?.addSubview(controller.view);
        
        self.window!.makeKeyAndVisible();
        
        
        
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}

