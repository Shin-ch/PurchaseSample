//
//  XXXProductManager.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import Foundation
import StoreKit


class ProductManager: NSObject, SKProductsRequestDelegate {
    
    static private var managers: Set<ProductManager> = Set()
    
    fileprivate var completion: ([SKProduct], Error?) -> Void
    
    init(completion: @escaping ([SKProduct], Error?) -> Void) {
        self.completion = completion
    }
    
    /// 課金アイテム情報を取得
    class func request(productIdentifiers: [String], completion: @escaping ([SKProduct], Error?) -> Void) {
        let productManager = ProductManager(completion: completion)
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        productRequest.start()
        productManager.productRequest = productRequest
        managers.insert(productManager)
    }
    
    // MARK: - SKProducts Request Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var error : NSError? = nil
        if response.products.count == 0 {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        }
        completion(response.products, error)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        let error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        completion([],error)
        ProductManager.managers.remove(self)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        ProductManager.managers.remove(self)
    }
    
}


// MARK: - Utility
extension SKProduct {
    /// おまけ 価格情報を抽出
    var localizedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = self.priceLocale
        return numberFormatter.string(from: self.price)!
    }
}


