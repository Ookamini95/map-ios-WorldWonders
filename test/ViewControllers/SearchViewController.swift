//
//  SearchViewController.swift
//  test
//
//  Created by Enrico on 31/07/24.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    let MapService = MapDataService.shared
    let searchBar = UISearchBar()
    
    private var cancellables: Set<AnyCancellable> = []
    
    weak var overlayDelegate: OverlayListDelegate?
    
    var searchStates: [SearchResult]?
    var searchValues = SearchValues()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSearchData()
        
        // Configure search bar
        searchBar.delegate = self
        searchBar.placeholder = "         Search" // Mamma mia un genio del male TODO: fix with padding
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = true
        
        setupSearchValuesSubscriber()
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
            searchTextField.clipsToBounds = true
            searchTextField.leftViewMode = .always
            
            // Create and set left view (back arrow)
            let search = UIButton(type: .custom)
            search.setImage(UIImage(named: "xml-search"), for: .normal)
            search.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Padding
            paddingView.addSubview(search)
            search.center = paddingView.center
            searchTextField.leftView = paddingView
            
            // Add bottom shadow
            searchTextField.layer.shadowColor = UIColor.black.cgColor
            searchTextField.layer.shadowOpacity = 0.15
            searchTextField.layer.shadowOffset = CGSize(width: 0, height: 3)
            searchTextField.layer.shadowRadius = 5
            searchTextField.layer.masksToBounds = false
        }
        
        // Create back button
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Set image for back button
        if let backButtonImage = UIImage(named: "back-button") {
            backButton.setImage(backButtonImage, for: .normal)
        }
        
        // Create horizontal stack view
        let stackView = UIStackView(arrangedSubviews: [backButton, searchBar])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding stack view to the main view
        view.addSubview(stackView)
        
        // Setup constraints for stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -15),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    @objc func backButtonTapped() {
        searchBar.resignFirstResponder()
        overlayDelegate?.dismissOverlay()
    }
    
    // UISearchBarDelegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        overlayDelegate?.presentOverlay()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            searchValues.filtered = filterValues(searchText: searchText)
        } else {
            resetSearchData()
        }
    }
    
    private func filterValues(searchText: String) -> [SearchResult] {
        guard let data = searchStates else {
            print("Could not get search state")
            return []
        }
        let filteredSearchResults = data.filter { card in
            let text = searchText.lowercased()
            return card.title.lowercased().contains(text)
        }
        
        return filteredSearchResults
    }
    
    private func initializeSearchData() {
        guard let data = MapService.getResultData() else {
            print("Could not initialize search data")
            return
        }
        searchStates = data.map { card in
            return card.toSearchResult()
        }
        resetSearchData()
    }
    
    private func resetSearchData() {
        searchValues.filtered = searchStates
    }
    
    private func setupSearchValuesSubscriber() {
        searchValues.$filtered
            .compactMap { $0 }
            .sink { [weak self] (filteredResults: [SearchResult]) in                
                for res in filteredResults {
                    guard res.searched else { continue }
                    if let index = self?.searchStates?.firstIndex(where: { ($0.id == res.id)}) {
                        self?.searchStates?[index].searched = true
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension CardItem {
    func toSearchResult() -> SearchResult {
        var data = SearchResult(title: self.name)
        data.id = self.id
        data.searched = false
        return data
    }
}
