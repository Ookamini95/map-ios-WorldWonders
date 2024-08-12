//
//  SlideshowViewController.swift
//  test
//
//  Created by Enrico on 01/08/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class SlideshowViewController: UIViewController {
    
    let MapService = MapDataService.shared
    
    var selectionDelegate: SelectableMarkerDelegate?
    var cardSelection: CardSelection?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Sample data
    override func viewDidLoad() {
        guard let cardSelection = self.cardSelection else { return }
        let cards = MapService.getResultData()
        let swiftUIView = SlideshowView(
                    selection: cardSelection,
                    cards: cards!,
                    selectionHandler: { title, lat, lng in
                        self.selectionDelegate?.selectMarker(byTitle: title, byCoordinates: (lat, lng))
                    },
                    detailsNavigationHandler: {
                        self.navigateToDetailsView()
                    }
            )
        
        // Create a UIHostingController with the SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        // Add the hosting controller as a child view controller
        addChild(hostingController)
        
        // Add the SwiftUI view to the view hierarchy
        view.addSubview(hostingController.view)
        
        // Set constraints for the SwiftUI view to be at the bottom
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 250)
        ])
        hostingController.didMove(toParent: self)
    }
    
    @objc func navigateToDetailsView() {
        let detailsVC = DetailsViewController()
        detailsVC.view.backgroundColor = .black
        detailsVC.cardItem = MapService.selectedCardItem
        print(detailsVC.cardItem)
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}
