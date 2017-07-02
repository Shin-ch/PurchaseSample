//
//  XXXProductManager.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import Foundation
import StoreKit


enum ProductManagerError: Error {
    case noProducts
    case unkown
    
    var localizedDescription: String {
        switch self {
        case .noProducts:
            return "プロダクトを取得できませんでした。"
        default:
            return "不明なエラー"
        }
    }
}

class ProductManager: NSObject {
    
    static fileprivate var managers: Set<ProductManager> = Set()
    
    fileprivate var completion: ([SKProduct], Error?) -> Void

    private var productRequest: SKProductsRequest?
    
    private init(completion: @escaping ([SKProduct], Error?) -> Void) {
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
    
}

// MARK: - SKProducts Request Delegate
extension ProductManager: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let error = response.products.isEmpty ? nil : ProductManagerError.noProducts
        completion(response.products, error)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
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
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price) ?? "--"
    }
}


