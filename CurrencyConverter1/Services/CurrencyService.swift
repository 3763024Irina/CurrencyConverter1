//
//  CurrencyService.swift
//  CurrencyConverter1
//
//  Created by Irina on 24/2/25.
//
import Foundation
import Alamofire

class CurrencyService {
    static let shared = CurrencyService()
    
    private let apiUrl = "https://api.exchangerate-api.com/v4/latest/USD"

    func fetchExchangeRates(completion: @escaping (ExchangeRate?) -> Void) {
        AF.request(apiUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученный JSON: \(jsonString)")
                }
                do {
                    let decodedData = try JSONDecoder().decode(ExchangeRate.self, from: data)
                    completion(decodedData)
                } catch {
                    print("Ошибка парсинга: \(error.localizedDescription)")
                    completion(nil)
                }

            case .failure(let error):
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
