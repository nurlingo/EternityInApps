//
//  File.swift
//  
//
//  Created by Daniya on 10/04/2020.
//


import UIKit
import StoreKit

public class PurchaseController: UIViewController {
    
    
    
    var prices = [String]()
    var products = [SKProduct]() {
        didSet {
            prices = []
            products.sort { Int($0.price) < Int($1.price) }
            for product in products {
                if IAPHelper.canMakePayments() {
                    PurchaseController.priceFormatter.locale = product.priceLocale
                    prices.append("\(PurchaseController.priceFormatter.string(from: product.price)!)")
                } else {
                    //not available for purchse
                }
            }
            pricePickerView.reloadAllComponents()
            activityIndicator.stopAnimating()
        }
    }
    
    var purchaseMade = false
    var productChosen: SKProduct?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let supportLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 30, y: 70, width: UIScreen.main.bounds.width - 60, height: 180)
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = UIColor.darkText
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = NSLocalizedString("SupportMessage", comment: "")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    private lazy var pricePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.tintColor = UIColor.darkText
        picker.frame = CGRect(x: 0, y: 250, width: UIScreen.main.bounds.width, height: 200)
        return picker
    }()
    
    
    private let supportButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.darkText, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.darkText.cgColor
        button.layer.cornerRadius = 5
        button.frame = CGRect(x: UIScreen.main.bounds.width * 0.5 - 75, y: UIScreen.main.bounds.height - 104, width: 150, height: 44)
        button.setTitle(NSLocalizedString("Support", comment: ""), for: UIControl.State())
        button.addTarget(self, action: #selector(supportButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //hiding nav bar bottom border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    private func setupViews() {
        
        self.view.addSubview(supportLabel)
        self.view.addSubview(pricePickerView)
        self.view.addSubview(supportButton)
        
    }
    
    override public func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            
            super.viewSafeAreaInsetsDidChange()
            
            let safeArea = self.view.safeAreaInsets
            
            self.supportButton.frame.origin.y = UIScreen.main.bounds.height - 104 - safeArea.bottom
            
        }
    }

    @objc private func handlePurchaseNotification(_ notification: Notification) {
        
        purchaseMade = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.pricePickerView.alpha = 0
            self.supportButton.alpha = 0
            self.supportLabel.alpha = 0
        }) { _ in
            self.supportLabel.text = NSLocalizedString("Thanks", comment: "")
            self.supportButton.setTitle(NSLocalizedString("YouGotIt", comment: ""), for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                self.supportLabel.alpha = 1
                self.supportButton.alpha = 1
            })
        }
    }
    
    
    
    
    @objc private func supportButtonPressed(_ sender: AnyObject) {
        
        if purchaseMade {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        activityIndicator.startAnimating()
        
        guard let product = productChosen else {
            activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        /// Analytics.logEvent("attempting_to_support", parameters: nil)
        /// Analytics.logEvent("attempting_to_buy_for_\(PurchaseController.priceFormatter.string(from: product.price)!)", parameters: nil)
        IAPProducts.supportStore.buyProduct(product)
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension PurchaseController: UIPickerViewDelegate, UIPickerViewDataSource  {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prices.count
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 19)
            pickerLabel?.textAlignment = NSTextAlignment.center
//            pickerLabel?.textColor = UIColor.random()
        }
        
        pickerLabel?.text = prices[row]
        
        return pickerLabel!;
    }
    
    

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        productChosen = products[row]
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 300.0
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    
}


