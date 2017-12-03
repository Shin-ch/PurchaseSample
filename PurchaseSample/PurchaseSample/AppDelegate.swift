//
//  AppDelegate.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,PurchaseManagerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // デリゲート設定
        PurchaseManager.shared.delegate = self
        
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.shared)
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.shared);
    }

    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        //課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
        /*
        
        
        TODO: コンテンツ解放処理
        
        
        */
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
}

