//
//  ViewController.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import UIKit
import StoreKit



class ViewController: UIViewController {
    
    let productIdentifiers : [String] = ["productIdentifier1"]
    
    @IBOutlet weak var label : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //プロダクト情報取得
        ProductManager.request(productIdentifiers: productIdentifiers,
                               completion: {[weak self] (products: [SKProduct], error: Error?) -> Void in
                                guard error == nil else {
                                    let text = (error as? ProductManagerError)?.localizedDescription ?? "error"
                                    self?.label?.text = text
                                    print(text)
                                    return
                                }
                                
                                for product in products {
                                    //価格を抽出
                                    let priceString = product.localizedPrice
                                    /*
                                     TODO: UI更新
                                     
                                     
                                     
                                     
                                     
                                     */
                                    let text = product.localizedTitle + " : \(priceString)"
                                    self?.label?.text = text
                                    print(text)
                                }
                                
        })
    }

    @IBAction func didTappPurchaseButton(_ sender: UIButton!) {
        //課金開始（サンプルでは"productIdentifier1"決め打ちで）
        guard let productIdentifier = productIdentifiers.first else { return }
        purchase(productIdentifier)
    }

    ///課金開始
    private func purchase(_ productId: String) {
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //プロダクト情報を取得
        ProductManager.request(productIdentifier: productId,
            completion: {[weak self]  (product: SKProduct?, error: Error?) -> Void in
                guard error == nil, let product = product else {
                    self?.purchaseManager(PurchaseManager.shared, didFailWithError: error)
                    return
                }
                
                //課金処理開始
                PurchaseManager.shared.purchase(product)
        })
    }

    /// リストア開始
    private func startRestore() {
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        
        //リストア開始
        PurchaseManager.shared.restore()
    }

}

// MARK: - PurchaseManager Delegate
extension ViewController: PurchaseManagerDelegate {
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

