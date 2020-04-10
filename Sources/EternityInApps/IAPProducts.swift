//
//  File.swift
//  
//
//  Created by Daniya on 11/04/2020.
//

import Foundation

public struct IAPProducts {
    
    public static let supportProductIdentifiers: Set<ProductIdentifier> = []
    
    public static let supportStore = IAPHelper(productIds: IAPProducts.supportProductIdentifiers)
    
    
}
