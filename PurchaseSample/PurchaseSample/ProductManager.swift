//
//  XXXProductManager.swift
//  PurchaseSample
//
//  Created by Shin on 2015/09/19.
//  Copyright © 2015年 Shin. All rights reserved.
//

import Foundation
import StoreKit


/// 価格情報取得エラー
public enum ProductManagerError: Error {
    case emptyProductIdentifiers
    case noValidProducts
    case notMatchProductIdentifier
    case unkown
    
    public var localizedDescription: String {
        switch self {
        case .emptyProductIdentifiers:
            return "プロダクトIDが指定されていません。"
        case .noValidProducts:
            return "有効なプロダクトを取得できませんでした。"
        case .notMatchProductIdentifier:
            return "指定したプロダクトIDと取得したプロダクトIDが一致していません。"
        default:
            return "不明なエラー"
        }
    }
}


/// 価格情報を取得するためのクラス
final public class ProductManager: NSObject {
    ///保持用
    static fileprivate var managers: Set<ProductManager> = Set()
    
    ///完了通知
    public typealias Completion = ([SKProduct], Error?) -> Void
    public typealias CompletionForSingle = (SKProduct?, Error?) -> Void
    
    ///完了通知用
    fileprivate var completion: Completion

    ///価格問い合わせ用オブジェクト(保持用)
    private var productRequest: SKProductsRequest?
    
    ///初期化
    private init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    /// 課金アイテム情報を取得(複数)
    class func request(productIdentifiers: [String], completion: @escaping Completion) {
        guard !productIdentifiers.isEmpty else {
            completion([], ProductManagerError.emptyProductIdentifiers)
            return
        }
        
        let productManager = ProductManager(completion: completion)
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        productRequest.start()
        productManager.productRequest = productRequest
        managers.insert(productManager)
    }
    
    /// 課金アイテム情報を取得(1つ)
    class func request(productIdentifier: String, completion: @escaping CompletionForSingle) {
        ProductManager.request(productIdentifiers: [productIdentifier]) { (products, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let product = products.first else {
                completion(nil, ProductManagerError.noValidProducts)
                return
            }
            
            guard product.productIdentifier == productIdentifier else {
                completion(nil, ProductManagerError.notMatchProductIdentifier)
                return
            }
            
            completion(product, nil)
        }
    }    
}

// MARK: - SKProducts Request Delegate
extension ProductManager: SKProductsRequestDelegate{
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let error = !response.products.isEmpty ? nil : ProductManagerError.noValidProducts
        completion(response.products, error)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        completion([],error)
        ProductManager.managers.remove(self)
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        ProductManager.managers.remove(self)
    }
}


// MARK: - Utility
public extension SKProduct {
    /// 価格
    var localizedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price) ?? "--"
    }
}


