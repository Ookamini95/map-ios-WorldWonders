//
//  DetailsViewController.swift
//  test
//
//  Created by Enrico on 01/08/24.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailsViewController: UIViewController {
    
    var cardItem: CardItem?
    
    private let imageView = UIImageView()
    private let contentView = UIView()
    private let infoView = UIView()
    private let generalInfoView = UIView()
    private var titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let generalInfoLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
        setupConstraints()
        configureContent()
    }
    
    private func setupViews() {
        title = "DETAILS"
        view.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(infoView)
        contentView.addSubview(generalInfoView)
        
        infoView.addSubview(titleLabel)
        infoView.addSubview(addressLabel)
        generalInfoView.addSubview(generalInfoLabel)
        
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = true
        
        generalInfoView.backgroundColor = .systemGray6
        generalInfoView.layer.masksToBounds = true
        
        titleLabel.numberOfLines = 0
        addressLabel.numberOfLines = 0
        generalInfoLabel.numberOfLines = 0
        
        imageView.contentMode = .scaleAspectFill
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        generalInfoView.translatesAutoresizingMaskIntoConstraints = false
        generalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            infoView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            infoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            infoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 175),
            
            
            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 30),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            addressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            generalInfoView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -20),
            generalInfoView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 0),
            generalInfoView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: 0),
            generalInfoView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.frame.height/2),
            
            generalInfoLabel.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 25),
            generalInfoLabel.leadingAnchor.constraint(equalTo: generalInfoView.leadingAnchor, constant: 30),
            generalInfoLabel.trailingAnchor.constraint(equalTo: generalInfoView.trailingAnchor, constant: -30),
        ])
    }
    
    private func configureContent() {
        guard let cardItem = cardItem else { return }
        
        titleLabel.text = "\(cardItem.name)"
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 22)
        titleLabel.textColor = UIColor(hex: "#5A5A63")
        
        addressLabel.text = "\(cardItem.address)"
        addressLabel.font = UIFont(name: "Poppins-Regular", size: 14)
        addressLabel.textColor = UIColor(hex: "#636363")
        
        generalInfoLabel.text = cardItem.generalInfo
        generalInfoLabel.font = UIFont(name: "Poppins-Regular", size: 14)
        generalInfoLabel.textColor = UIColor(hex: "#313131")
        
        if let url = URL(string: cardItem.cover) {
            imageView.af.setImage(withURL: url)
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        
        return nil
    }
}

