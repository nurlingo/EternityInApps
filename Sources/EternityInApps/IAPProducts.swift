//
//  File.swift
//  
//
//  Created by Daniya on 11/04/2020.
//

import Foundation

internal struct IAPProducts {
    
    static var purchaseProductIdentifiers: Set<ProductIdentifier> = []
    
    static let purchaseStore = IAPHelper(productIds: IAPProducts.purchaseProductIdentifiers)
    
    
}
