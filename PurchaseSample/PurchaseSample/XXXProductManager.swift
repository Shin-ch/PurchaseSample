//
//  XXXProductManager.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import Foundation
import StoreKit

private var productManagers : Set<XXXProductManager> = Set()

class XXXProductManager: NSObject, SKProductsRequestDelegate {
    
    private var completionForProductidentifiers : (([SKProduct]!,NSError?) -> Void)?
    
    /// 課金アイテム情報を取得
    class func productsWithProductIdentifiers(productIdentifiers : [String]!,completion:(([SKProduct]!,NSError?) -> Void)?){
        let productManager = XXXProductManager()
        productManager.completionForProductidentifiers = completion
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        productRequest.start()
        productManagers.insert(productManager)
    }
    
    // MARK: - SKProducts Request Delegate
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var error : NSError? = nil
        if response.products.count == 0 {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        }
        completionForProductidentifiers?(response.products, error)
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        let error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        completionForProductidentifiers?(nil,error)
        productManagers.remove(self)
    }
    
    func requestDidFinish(request: SKRequest) {
        productManagers.remove(self)
    }
    
    // MARK: - Utility
    /// おまけ 価格情報を抽出
    class func priceStringFromProduct(product: SKProduct!) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = .Behavior10_4
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.locale = product.priceLocale
        return numberFormatter.stringFromNumber(product.price)!
    }
    
}