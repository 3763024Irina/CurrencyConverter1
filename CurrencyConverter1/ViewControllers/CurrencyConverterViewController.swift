import UIKit
import Alamofire

struct ExchangeRatesResponse: Decodable {
    let rates: [String: Double]
}

class CurrencyConverterViewController: UIViewController {
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите сумму"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.backgroundColor = UIColor(white: 1, alpha: 0.9)
        textField.layer.cornerRadius = 10
        textField.layer.shadowColor = UIColor.gray.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.3
        return textField
    }()
    
    private let fromCurrencyButton: UIButton = createStyledButton(title: "Выбрать валюту")
    private let toCurrencyButton: UIButton = createStyledButton(title: "Выбрать валюту")
    private let convertButton: UIButton = createStyledButton(title: "Конвертировать")
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Результат"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var currencies: [String: Double] = [:]
    private var selectedFromCurrency: String? {
        didSet { updateButtonBackground(button: fromCurrencyButton, currency: selectedFromCurrency) }
    }
    private var selectedToCurrency: String? {
        didSet { updateButtonBackground(button: toCurrencyButton, currency: selectedToCurrency) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCurrencies()
        
        fromCurrencyButton.addTarget(self, action: #selector(selectFromCurrency), for: .touchUpInside)
        toCurrencyButton.addTarget(self, action: #selector(selectToCurrency), for: .touchUpInside)
        convertButton.addTarget(self, action: #selector(convertCurrency), for: .touchUpInside)
    }
    
    private func updateButtonBackground(button: UIButton, currency: String?) {
        if let currency = currency {
            button.setTitle(currency, for: .normal)
            button.backgroundColor = UIColor.systemOrange
        } else {
            button.setTitle("Выбрать валюту", for: .normal)
            button.backgroundColor = UIColor.systemGreen
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBlue
        
        let stackView = UIStackView(arrangedSubviews: [amountTextField, fromCurrencyButton, toCurrencyButton, convertButton, resultLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func selectFromCurrency() {
        showCurrencyPicker { selectedCurrency in
            self.selectedFromCurrency = selectedCurrency
        }
    }
    
    @objc private func selectToCurrency() {
        showCurrencyPicker { selectedCurrency in
            self.selectedToCurrency = selectedCurrency
        }
    }
    
    @objc private func convertCurrency() {
        guard let amountText = amountTextField.text, let amount = Double(amountText),
              let fromCurrency = selectedFromCurrency, let toCurrency = selectedToCurrency,
              let fromRate = currencies[fromCurrency], let toRate = currencies[toCurrency] else {
            showErrorAlert(message: "Выберите валюты и введите сумму")
            return
        }
        
        let convertedAmount = (amount / fromRate) * toRate
        resultLabel.text = String(format: "%.2f %@", convertedAmount, toCurrency)
    }
    
    private func fetchCurrencies() {
        guard currencies.isEmpty else { return }
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "EXCHANGE_API_KEY") as? String, !apiKey.isEmpty else {
            showErrorAlert(message: "API-ключ отсутствует!")
            return
        }
        
        let url = "https://api.exchangeratesapi.io/v1/latest?access_key=\(apiKey)&base=EUR"
        
        activityIndicator.startAnimating()
        
        AF.request(url).responseDecodable(of: ExchangeRatesResponse.self) { response in
            self.activityIndicator.stopAnimating()
            switch response.result {
            case .success(let exchangeRates):
                self.currencies = exchangeRates.rates
                print("Курсы валют загружены: \(exchangeRates.rates)")
            case .failure:
                self.showErrorAlert(message: "Не удалось загрузить курсы валют")
            }
        }
    }
    
    private func showCurrencyPicker(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Выберите валюту", message: nil, preferredStyle: .actionSheet)
        
        for currency in currencies.keys.sorted() {
            alert.addAction(UIAlertAction(title: currency, style: .default, handler: { _ in
                completion(currency)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private static func createStyledButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
