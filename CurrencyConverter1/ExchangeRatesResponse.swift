//
//  ExchangeRatesResponse.swift
//  CurrencyConverter1
//
//  Created by Irina on 24/2/25.
//

import Foundation
import Foundation

struct ExchangeRatesResponse: Decodable {
    let rates: [String: Double]
}
