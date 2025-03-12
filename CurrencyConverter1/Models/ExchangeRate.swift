//
//  Models.swift
//  CurrencyConverter1
//
//  Created by Irina on 24/2/25.
//

import Foundation

struct ExchangeRate: Decodable {
    let base: String
    let rates: [String: Double]
}
