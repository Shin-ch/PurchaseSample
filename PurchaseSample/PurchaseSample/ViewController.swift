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
    
    @IBAction func purchaseButton(_ sender:UIButton!) {
        //課金開始（サンプルでは"productIdentifier1"決め打ちで）
        purchase(productIdentifiers[0])
    }

    ///プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
        ProductManager.request(productIdentifiers: productIds,
            completion: {[weak self] (products: [SKProduct], error: Error?) -> Void in
                if error != nil {
                    self?.label?.text = error?.localizedDescription
                    print(error?.localizedDescription ?? "error")
                    return
                }
                
                for product in products {
                    //価格を抽出
                    let priceString = product.localizedPrice
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
    fileprivate func purchase(_ productId:String) {
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //プロダクト情報を取得
        ProductManager.request(productIdentifiers: [productId],
            completion: {[weak self]  (products: [SKProduct], error: Error?) -> Void in
                if error != nil {
                    self?.purchaseManager(PurchaseManager.shared, didFailWithError: error)
                    return
                }
                
                if products.count > 0 {
                    //課金処理開始
                    PurchaseManager.shared.start(products[0])
                }
        })
    }

    /// リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //リストア開始
        PurchaseManager.shared.startRestore()
    }
    
    
    // MARK: - XXXPurchaseManager Delegate
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        //課金終了時に呼び出される
        /*
        TODO: コンテンツ解放処理

        
        
        
        
        */
        let ac = UIAlertController(title: "purchase finish!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
        /*
        TODO: コンテンツ解放処理
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purchase finish!(Untreated.)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)

    
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFailWithError error: Error?) {
        //課金失敗時に呼び出される
        /*
        TODO: errorを使ってアラート表示
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purchase fail...", message: error?.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        /*
        TODO: インジケータなどを表示していたら非表示に
        
        
        
        
        
        */
        let ac = UIAlertController(title: "restore finish!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        /* 
        TODO: インジケータなどを表示していたら非表示に
        
        
        
        
        
        */
        let ac = UIAlertController(title: "purcase defferd.", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    


}

