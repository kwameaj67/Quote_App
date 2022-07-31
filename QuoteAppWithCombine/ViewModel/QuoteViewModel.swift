//
//  QuoteViewModel.swift
//  QuoteAppWithCombine
//
//  Created by Kwame Agyenim - Boateng on 26/07/2022.
//

import Foundation
import Combine


class QuoteViewModel{
    private var cancellables = Set<AnyCancellable>()
//    input is what the viewController sends to the viewModel
    enum Input{
        case viewDidAppear
        case refreshButtonDidTap
    }
//    output is what the viewModel sends to the viewController after process data
    enum Output{
        case fetchQuoteDidFail(error:Error)
        case fetchQuoteDidSucceed(quote: Quote)
        case toggleButton(isEnabled:Bool)
        case toggleLoading(loading: Bool)
    }
    
    // injecting this service
    private let quoteServiceType: QuoteServiceType
    private let output : PassthroughSubject<Output, Never> = .init()
    
    init(quoteServiceType: QuoteServiceType = QuoteService()) {
        self.quoteServiceType = quoteServiceType
    }
    func getRandomQuote(){
        output.send(.toggleLoading(loading: true))
        output.send(.toggleButton(isEnabled: false))
        quoteServiceType.getRandomQuote().sink { [weak self] completion in
            self?.output.send(.toggleLoading(loading: false))
            self?.output.send(.toggleButton(isEnabled: true))
            switch completion {
            case .failure(let error):
//                tell output to handle the error
                self?.output.send(.fetchQuoteDidFail(error: error))
            case .finished:
                print("Random quote received")
            }
        } receiveValue: { [weak self] quote in
            self?.output.send(.fetchQuoteDidSucceed(quote: quote))
        }.store(in: &cancellables)

    }
    // this function transform an input to an output
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>{
//        checks what input type
        input.sink { [weak self] event in
            switch event{
            case .refreshButtonDidTap, .viewDidAppear:
                self?.getRandomQuote()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}
