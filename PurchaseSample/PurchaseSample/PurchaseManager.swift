//
//  XXXPurchaseManager.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import Foundation
import StoreKit


struct PurchaseManagerErrors: OptionSet, Error {
    let rawValue: Int
    static let cannotMakePayments   = PurchaseManagerErrors(rawValue: 1 << 0)
    static let purchasing           = PurchaseManagerErrors(rawValue: 1 << 1)
    static let restoreing           = PurchaseManagerErrors(rawValue: 1 << 2)
    
    var localizedDescription: String {
        var message = ""
        
        if self.contains(.cannotMakePayments) {
            message += "設定で購入が無効になっています。"
        }
        
        if self.contains(.purchasing) {
            message += "課金処理中です。"
        }
        
        if self.contains(.restoreing) {
            message += "リストア中です。"
        }
        return message
    }
}

class PurchaseManager : NSObject,SKPaymentTransactionObserver {
    
    open static var shared = PurchaseManager()

    weak var delegate : PurchaseManagerDelegate?
    
    private var productIdentifier : String?
    private var isRestore : Bool = false
    
    /// 課金開始
    func start(_ product: SKProduct){
        
        var errors: PurchaseManagerErrors = []
        
        if SKPaymentQueue.canMakePayments() == false {
            errors.insert(.cannotMakePayments)
        }
        
        if productIdentifier != nil {
            errors.insert(.purchasing)
        }
        
        if isRestore == true {
            errors.insert(.restoreing)
        }
        
        //エラーがあれば終了
        guard errors.isEmpty else {
            delegate?.purchaseManager?(self, didFailWithError: errors)
            return
        }
        
        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions 
        for transaction in transactions {
            if transaction.transactionState != .purchased { continue }
            if transaction.payment.productIdentifier == product.productIdentifier {
                guard let window = UIApplication.shared.delegate?.window else { continue }
                let ac = UIAlertController(title: nil, message: "\(product.localizedTitle)は購入処理が中断されていました。\nこのまま無料でダウンロードできます。", preferredStyle: .alert)
                let action = UIAlertAction(title: "続行", style: UIAlertActionStyle.default, handler: {[weak self] (action : UIAlertAction!) -> Void in
                    if let weakSelf = self {
                        weakSelf.productIdentifier = product.productIdentifier
                        weakSelf.completeTransaction(transaction)
                    }
                })
                ac.addAction(action)
                window!.rootViewController?.present(ac, animated: true, completion: nil)
                return
            }
        }
        
        //課金処理開始
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        productIdentifier = product.productIdentifier
    }
    
    /// リストア開始
    func startRestore(){
        if isRestore == false {
            isRestore = true
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else{
            delegate?.purchaseManager?(self, didFailWithError: PurchaseManagerErrors.restoreing)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //課金状態が更新されるたびに呼ばれる
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing :
                //課金中
                break
            case .purchased :
                //課金完了
                completeTransaction(transaction)
                break
            case .failed :
                //課金失敗
                failedTransaction(transaction)
                break
            case .restored :
                //リストア
                restoreTransaction(transaction)
                break
            case .deferred :
                //承認待ち
                deferredTransaction(transaction)
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        //リストア失敗時に呼ばれる
        delegate?.purchaseManager?(self, didFailWithError: error)
        isRestore = false
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //リストア完了時に呼ばれる
        delegate?.purchaseManagerDidFinishRestore?(self)
        isRestore = false
    }
    
    
    
    // MARK: - SKPaymentTransaction process
    private func completeTransaction(_ transaction : SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            productIdentifier = nil
        }else{
            //課金終了(以前中断された課金処理)
            delegate?.purchaseManager?(self, didFinishUntreatedPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
    
    private func failedTransaction(_ transaction : SKPaymentTransaction) {
        //課金失敗
        delegate?.purchaseManager?(self, didFailWithError: transaction.error)
        productIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction : SKPaymentTransaction) {
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }
    
    private func deferredTransaction(_ transaction : SKPaymentTransaction) {
        //承認待ち
        delegate?.purchaseManagerDidDeferred?(self)
        productIdentifier = nil
    }
}


@objc protocol PurchaseManagerDelegate {
    ///課金完了
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction, decisionHandler: (_ complete: Bool) -> Void)
    ///課金完了(中断していたもの)
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction, decisionHandler: (_ complete: Bool) -> Void)
    ///リストア完了
    @objc optional func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager)
    ///課金失敗
    @objc optional func purchaseManager(_ purchaseManager: PurchaseManager, didFailWithError error: Error?)
    ///承認待ち(ファミリー共有)
    @objc optional func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager)
}
