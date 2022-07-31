//
//  WebService.swift
//  QuoteAppWithCombine
//
//  Created by Kwame Agyenim - Boateng on 26/07/2022.
//

import Foundation
import Combine

enum ErrorType: Error{
    case invalidURL
    case noResponse
}

protocol QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote,Error>
}
class QuoteService: QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        guard let url = URL(string: "https://api.quotable.io/random") else {
             fatalError("Invalid URL")
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }
//            .map({ $0.data })
//            .decode(type: Quote.self, decoder: JSONDecoder())
            .tryMap { data, _ in
                try JSONDecoder().decode(Quote.self, from: data)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
}
