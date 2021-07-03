//
//  AppDelegate.swift
//  AstroSwift
//
//  Created by Dalton Claybrook on 7/3/21.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NASAAPIKey.assertKeyIsSet()
        return true
    }
}
