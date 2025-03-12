import UIKit

class CurrencySelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView = UITableView()
    var currencies: [Currency] = [
        Currency(code: "USD", name: "Доллар США"),
        Currency(code: "EUR", name: "Евро"),
        Currency(code: "RUB", name: "Российский рубль")
    ]
    
    var onCurrencySelected: ((Currency) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Выберите валюту"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrencyCell.self, forCellReuseIdentifier: "CurrencyCell")

        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        cell.textLabel?.text = currencies[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onCurrencySelected?(currencies[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}
