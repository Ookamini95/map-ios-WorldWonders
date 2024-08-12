//
//  OverlayListViewController.swift
//  test
//
//  Created by Enrico on 31/07/24.
//

import Foundation
import UIKit
import SwiftUI

class OverlayListViewController: UIViewController {
    
    weak var selectionDelegate: SelectableMarkerDelegate?
    weak var overlayDelegate: OverlayListDelegate?
    
    var searchViewHost: UIHostingController<SearchResultsView>?
    var searchValues: SearchValues?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let searchValues = self.searchValues else {
            print("Invalid search object")
            return
        }
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        let swiftUIView = SearchResultsView(
            searchValues: searchValues,
            selectionHandler: { id in
                searchValues.setSearched(withId: id)
                self.overlayDelegate?.dismissOverlay()
                self.selectionDelegate?.selectMarker(byTitle: "\(id)", byCoordinates: nil)
            }
        )
        let hostingController = UIHostingController(rootView: swiftUIView)
        searchViewHost = hostingController
        
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
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            hostingController.view.heightAnchor.constraint(equalToConstant: 650)
        ])
        hostingController.didMove(toParent: self)
    }
}
