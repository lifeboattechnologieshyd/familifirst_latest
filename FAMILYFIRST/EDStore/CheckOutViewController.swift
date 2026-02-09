//
//  CheckOutViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class CheckOutViewController: UIViewController {
    
    var selectedProduct: Product?
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var buynowButton: UIButton!
    @IBOutlet weak var gstLbl: UILabel!
    @IBOutlet weak var bottomVw: UIView!
    
    var savedAddresses: [AddressModel] = []
    var selectedAddress: AddressModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "CheckOutImageTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckOutImageTableViewCell")
        tblVw.register(UINib(nibName: "DescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "DescriptionTableViewCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
        
        tblVw.separatorStyle = .none
        
        topbarVw.addBottomShadow()
        bottomVw.addTopShadow()
        
        setupProductDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAddressAPI()
    }
    
    private func setupProductDetails() {
        guard let product = selectedProduct else { return }
        
        // Set final price with GST
        let finalPrice = Double(product.finalPrice) ?? 0
        let gstAmount = Double(product.gstAmount ?? "0") ?? 0
        let totalAmount = finalPrice + gstAmount
        
        amountLbl.text = "₹\(Int(totalAmount))"
        
        // Set GST amount
        if gstAmount > 0 {
            gstLbl.text = "GST: ₹\(Int(gstAmount))"
        } else {
            gstLbl.text = "GST: Included"
        }
    }
    
    func getAddressAPI() {
        showLoader()
        NetworkManager.shared.request(
            urlString: API.ONLINE_STORE_ADDRESS,
            method: .GET,
            parameters: nil,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<[AddressModel]>, NetworkError>) in
            
            DispatchQueue.main.async {
                self?.hideLoader()
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let addresses = response.data, !addresses.isEmpty {
                        self.savedAddresses = addresses
                        self.selectedAddress = addresses.first
                        self.updateDeliveryLabel()
                    } else {
                        self.savedAddresses = []
                        self.selectedAddress = nil
                        self.deliveryLbl.text = "Add your Delivery Address"
                    }
                    
                case .failure(let error):
                    print("Address Fetch Error:", error)
                    self.savedAddresses = []
                    self.selectedAddress = nil
                    self.deliveryLbl.text = "Add your Delivery Address"
                }
            }
        }
    }
    
    func updateDeliveryLabel() {
        guard let address = selectedAddress else {
            deliveryLbl.text = "Add your Delivery Address"
            return
        }
        
        let displayAddress = getDisplayAddress(from: address)
        
        if displayAddress.isEmpty {
            deliveryLbl.text = "Add your Delivery Address"
        } else {
            deliveryLbl.text = displayAddress
            deliveryLbl.textColor = .black
        }
    }
    
    func getDisplayAddress(from address: AddressModel) -> String {
        var addressComponents: [String] = []
        
        if let houseNo = address.fullAddress?.houseNo, !houseNo.isEmpty {
            addressComponents.append(houseNo)
        }
        if let street = address.fullAddress?.street, !street.isEmpty {
            addressComponents.append(street)
        }
        if let landmark = address.fullAddress?.landmark, !landmark.isEmpty {
            addressComponents.append(landmark)
        }
        if let village = address.fullAddress?.village, !village.isEmpty {
            addressComponents.append(village)
        }
        if let district = address.fullAddress?.district, !district.isEmpty {
            addressComponents.append(district)
        }
        if let place = address.placeName, !place.isEmpty {
            addressComponents.append(place)
        }
        if let state = address.stateName, !state.isEmpty {
            addressComponents.append(state)
        }
        if let pin = address.pinCode, !pin.isEmpty {
            addressComponents.append(pin)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func changeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let saveAddressVC = storyboard.instantiateViewController(withIdentifier: "SaveAddressVC") as? SaveAddressVC {
            saveAddressVC.existingAddress = selectedAddress
            self.navigationController?.pushViewController(saveAddressVC, animated: true)
        }
    }
    
    @IBAction func buyNowButtonTapped(_ sender: UIButton) {
        guard selectedAddress != nil else {
            showAlert("Please add a delivery address first")
            return
        }
        
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "MakePaymentViewController") as? MakePaymentViewController {
            nextVC.selectedProduct = selectedProduct
            nextVC.selectedAddress = selectedAddress
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CheckOutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = selectedProduct else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOutImageTableViewCell", for: indexPath) as! CheckOutImageTableViewCell
            cell.selectionStyle = .none
            
            cell.imgVw.setImage(url: product.thumbnailImage, placeHolderImage: "FF Logo")
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell", for: indexPath) as! DescriptionTableViewCell
            cell.selectionStyle = .none
            
            configureDescriptionCell(cell, with: product)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    private func configureDescriptionCell(_ cell: DescriptionTableViewCell, with product: Product) {
        
        cell.aboutLbl.text = product.itemName
        
        cell.descriptionTv.text = product.itemDescription ?? "No description available"
        
        let finalPrice = Double(product.finalPrice) ?? 0
        cell.amount2Lbl.text = "₹\(Int(finalPrice))"
        
        cell.mrpLbl.text = "MRP"
        
        let mrpValue = Double(product.mrp) ?? 0
        
        if mrpValue > 0 && mrpValue > finalPrice {
            let mrpText = "₹\(Int(mrpValue))"
            cell.setStrikethroughPrice(mrpText, shouldStrike: true)
            cell.strikeOutPrice.isHidden = false
            cell.mrpLbl.isHidden = false
        } else {
            cell.strikeOutPrice.isHidden = true
            cell.mrpLbl.isHidden = true
        }

        if let discountTag = product.discountTag, !discountTag.isEmpty {
            cell.offLbl.text = discountTag
            cell.offLbl.isHidden = false
        } else {
            if mrpValue > 0 && finalPrice > 0 && mrpValue > finalPrice {
                let discountPercent = Int(((mrpValue - finalPrice) * 100) / mrpValue)
                cell.offLbl.text = "\(discountPercent)% off"
                cell.offLbl.isHidden = false
            } else {
                cell.offLbl.isHidden = true
            }
        }
        
        let highlights = product.highlights ?? []
        if !highlights.isEmpty {
            cell.interestingLbl.text = "• " + highlights.joined(separator: "\n• ")
        } else {
            cell.interestingLbl.text = "No highlights available"
        }
        
        cell.configureVariantViews(with: product)
        
        let gstAmount = Double(product.gstAmount ?? "0") ?? 0
        let totalAmount = finalPrice + gstAmount
        self.amountLbl.text = "₹\(Int(totalAmount))"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 212
        case 1: return 550  
        default: return 400
        }
    }
}
