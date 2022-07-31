//
//  ViewController.swift
//  QuoteAppWithCombine
//
//  Created by Kwame Agyenim - Boateng on 26/07/2022.
//

import UIKit
import Combine

class QuoteViewController: UIViewController {

    private let viewModel = QuoteViewModel()
    private let input : PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "QuoteApp "
        setupNavigationBar()
        setupConstraints()
        setupBinders()
    }
    override func loadView() {
        super.loadView()
        [stackView,label,loader,button].forEach { item in
            self.view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 25.0
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .equalSpacing
//        sv.backgroundColor = .red
        return sv
    }()
    let label: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont(name: "AvenirNext-Medium", size: 26)
        lb.numberOfLines = 0
        lb.isHidden = true
        return lb
    }()
    let button: UIButton = {
        var btn = UIButton()
        btn.setTitle("Refresh", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        btn.addTarget(self, action: #selector(onTapRefresh), for: .touchUpInside)
        btn.layer.cornerRadius = 10.0
        return btn
    }()
    let loader: UIActivityIndicatorView = {
        var loader = UIActivityIndicatorView(frame: .zero)
        loader.style = .medium
        return loader
    }()
    
    @objc func onTapRefresh(){
        print("you tapped me!")
        input.send(.refreshButtonDidTap)
    }
    private func setupBinders(){
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.sink { [weak self] event in
            switch event{
            case .fetchQuoteDidSucceed(let quote):
                self?.label.text = quote.content
            case .fetchQuoteDidFail(let error):
                self?.label.text = error.localizedDescription
            case .toggleButton(let isEnabled):
                self?.button.isEnabled = isEnabled
                self?.button.backgroundColor = isEnabled ? .systemBlue : .systemGray5
            case .toggleLoading(let loading):
                loading ? self?.loader.startAnimating() : self?.loader.stopAnimating()
                if(loading == false){
                    self?.label.isHidden = false
                    self?.loader.isHidden = true
                }
                
            }
        }
        .store(in: &cancellables)
    }
}

extension QuoteViewController{
    func setupNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 24.0)!]
        
    }
    func setupConstraints(){
        [label,loader,button].forEach { item in
            stackView.addArrangedSubview(item)
        }
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            
            button.heightAnchor.constraint(equalToConstant: 56),
            button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -10)
            
        ])

    }
}
