//
//  ViewController.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import UIKit
import StoreKit


let productIdentifiers : [String] = ["productIdentifier1","productIdentifier2"]

class ViewController: UIViewController,XXXPurchaseManagerDelegate {
    
    
    @IBOutlet weak var label : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //プロダクト情報取得
        fetchProductInformationForIds(productIdentifiers)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func purchaseButton(sender:UIButton!) {
        //課金開始（サンプルでは"productIdentifier1"決め打ちで）
        purchase(productIdentifiers[0])
    }

    ///プロダクト情報取得
    private func fetchProductInformationForIds(productIds:[String]) {
        XXXProductManager.productsWithProductIdentifiers(productIds,
            completion: {[weak self] (products : [SKProduct]!, error : NSError?) -> Void in
                if error != nil {
                    if let weakSelf = self {
                        weakSelf.label?.text = error?.localizedDescription
                    }
                    print(error?.localizedDescription)
                    return
                }
                
                for product in products {
                    //価格を抽出
                    let priceString = XXXProductManager.priceStringFromProduct(product)
                    /*
                    TODO: UI更新
                    
                    
                    
                    
                    
                    */
                    if let weakSelf = self {
                        weakSelf.label?.text = product.localizedTitle + ":\(priceString)"
                    }
                    print(product.localizedTitle + ":\(priceString)" )
                }
        })
    }
    
    ///課金開始
    private func purchase(productId:String) {
        //デリゲード設定
        XXXPurchaseManager.sharedManager().delegate = self
        
        //プロダクト情報を取得
        XXXProductManager.productsWithProductIdentifiers([productId],
            completion: {[weak self]  (products : [SKProduct]!, error : NSError?) -> Void in
                if error != nil {
                    if let weakSelf = self {
                        weakSelf.purchaseManager(XXXPurchaseManager.sharedManager(), didFailWithError: error)
                    }
                    return
                }
                
                if products.count > 0 {
                    //課金処理開始
                    XXXPurchaseManager.sharedManager().startWithProduct(products[0])
                }
        })
    }

    /// リストア開始
    func startRestore() {
        //デリゲード設定
        XXXPurchaseManager.sharedManager().delegate = self
        
        //リストア開始
        XXXPurchaseManager.sharedManager().startRestore()
    }
    
    
    // MARK: - XXXPurchaseManager Delegate
    func purchaseManager(purchaseManager: XXXPurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((complete: Bool) -> Void)!) {
        //課金終了時に呼び出される
        /*
        TODO: コンテンツ解放処理

        
        
        
        
        */
        let ac = UIAlertController(title: "purchase finish!", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(complete: true)
    }
    
    func purchaseManager(purchaseManager: XXXPurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((complete: Bool) -> Void)!) {
        //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
        /*
        TODO: コンテンツ解放処理
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purchase finish!(Untreated.)", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)

    
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(complete: true)
    }
    
    func purchaseManager(purchaseManager: XXXPurchaseManager!, didFailWithError error: NSError!) {
        //課金失敗時に呼び出される
        /*
        TODO: errorを使ってアラート表示
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purchase fail...", message: error.localizedDescription, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)

    }
    
    func purchaseManagerDidFinishRestore(purchaseManager: XXXPurchaseManager!) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        /*
        TODO: インジケータなどを表示していたら非表示に
        
        
        
        
        
        */
        let ac = UIAlertController(title: "restore finish!", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func purchaseManagerDidDeferred(purchaseManager: XXXPurchaseManager!) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        /* 
        TODO: インジケータなどを表示していたら非表示に
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purcase defferd.", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    


}

