//
//  File.swift
//  
//
//  Created by Daniya on 10/04/2020.
//


import UIKit
import StoreKit

public class PurchaseController: UIViewController {
    
    public var productIdentifiers: [ProductIdentifier] = []
    public var salesPitchMessage: String = "Please make a purchase"
    public var thankYouMessage: String = "Thank you for your purchase!"
    public var purchaseFailedMessage: String = "Purchase failed to complete"
    public var purchaseButtonTitle: String = "Purchase"
    public var youGotItButtonTitle: String = "You got it"
    public var tryAgainButtonTitle: String = "Try again"
    
    public var freePrice: String = "FreePrice"
    public var canGetForFree: Bool = false
    
    public lazy var proceedAction: () -> Void = {
      self.dismiss(animated: true, completion: nil)
    }
    
    public lazy var closeAction: () -> Void = {
      self.dismiss(animated: true, completion: nil)
    }
    
    private var prices = [String]()
    private var products = [SKProduct]() {
        didSet {
            prices = canGetForFree ? [freePrice] : []
            
            products.sort { Int(truncating: $0.price) < Int(truncating: $1.price) }
            for product in products {
                if IAPHelper.canMakePayments() {
                    PurchaseController.priceFormatter.locale = product.priceLocale
                    prices.append("\(PurchaseController.priceFormatter.string(from: product.price)!)")
                } else {
                    //not available for purchse
                }
            }
            
            productChosen = canGetForFree ? nil : products.first
            
            DispatchQueue.main.async {
                self.pricePickerView.reloadAllComponents()
                self.activityIndicator.stopAnimating()
                self.purchaseButton.isHidden = false
                self.salesPitchLabel.isHidden = false
            }
        }
    }
    
    private var purchaseMade = false
    private var productChosen: SKProduct?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x:  UIScreen.main.bounds.width/2 - 25, y: 200, width: 50, height: 50)
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var salesPitchLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 30, y: 70, width: UIScreen.main.bounds.width - 60, height: 180)
        label.font = UIFont.systemFont(ofSize: 21)
        label.textColor = UIColor.darkText
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text = salesPitchMessage
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
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
    
    
    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.darkText, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.darkText.cgColor
        button.layer.cornerRadius = 5
        button.frame = CGRect(x: UIScreen.main.bounds.width * 0.5 - 75, y: UIScreen.main.bounds.height - 104, width: 150, height: 44)
        button.setTitle(purchaseButtonTitle, for: UIControl.State())
        button.addTarget(self, action: #selector(purchaseButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 254/255, green: 254/255, blue: 225/255, alpha: 1.0)
        
        //hiding nav bar bottom border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonPressed(_:)))
        
        setupViews()
        loadPurchases()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseController.handleFailueNotification(_:)),
        name: NSNotification.Name(rawValue: IAPHelper.IAPHelperFailureNotification),
        object: nil)
    }
    
    private func setupViews() {
        
        self.view.addSubview(salesPitchLabel)
        self.view.addSubview(pricePickerView)
        self.view.addSubview(purchaseButton)
        self.view.addSubview(activityIndicator)
        
    }
    
    private func loadPurchases() {
        activityIndicator.startAnimating()
        
        IAPProducts.purchaseProductIdentifiers = Set(productIdentifiers)
        IAPProducts.purchaseStore.requestProducts{success, productArray in
                        
            if success {
                self.products = productArray!
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override public func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            
            super.viewSafeAreaInsetsDidChange()
            
            let safeArea = self.view.safeAreaInsets
            
            self.purchaseButton.frame.origin.y = UIScreen.main.bounds.height - 124 - safeArea.bottom
            
        }
    }

    @objc private func handlePurchaseNotification(_ notification: Notification) {
        
        self.activityIndicator.stopAnimating()
        purchaseMade = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.pricePickerView.alpha = 0
            self.purchaseButton.alpha = 0
            self.salesPitchLabel.alpha = 0
        }) { _ in
            self.salesPitchLabel.text = self.thankYouMessage
            self.purchaseButton.setTitle(self.youGotItButtonTitle, for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                self.salesPitchLabel.alpha = 1
                self.purchaseButton.alpha = 1
            })
        }
    }
    
    @objc private func handleFailueNotification(_ notification: Notification) {
                
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.purchaseButton.alpha = 0
            self.salesPitchLabel.alpha = 0
        }) { _ in
            self.salesPitchLabel.text = self.purchaseFailedMessage
            self.purchaseButton.setTitle(self.tryAgainButtonTitle, for: .normal)
            UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
                self.salesPitchLabel.alpha = 1
                self.purchaseButton.alpha = 1
            })
        }
    }
    
    @objc private func purchaseButtonPressed(_ sender: AnyObject) {
        
        if purchaseMade {
            proceedAction()
            return
        }
        
        activityIndicator.startAnimating()
        
        guard let product = productChosen else {
            activityIndicator.stopAnimating()
            proceedAction()
            return
        }
        
        /// Analytics.logEvent("attempting_to_purchase", parameters: nil)
        /// Analytics.logEvent("attempting_to_buy_for_\(PurchaseController.priceFormatter.string(from: product.price)!)", parameters: nil)
        IAPProducts.purchaseStore.buyProduct(product)
    }
    
    @objc private func closeButtonPressed(_ sender: Any) {
        closeAction()
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
        
        guard canGetForFree else {
            productChosen = products[row]
            return
        }
        
        if row > 0 {
            productChosen = products[row-1]
        } else {
            productChosen = nil
        }
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 300.0
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    
}


