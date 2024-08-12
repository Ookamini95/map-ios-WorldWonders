//
//  ViewController.swift
//  test
//
//  Created by Enrico on 31/07/24.
//

import Mapbox
import UIKit
import SwiftUI

// TODO: Protocol group
protocol OverlayListDelegate: AnyObject {
    func dismissOverlay()
    func presentOverlay()
}
protocol SelectableMarkerDelegate: AnyObject {
    func selectMarker(byTitle title: String?, byCoordinates coordinates: (latitude: Double, longitude: Double)?)
}


class MapViewController: UIViewController, MGLMapViewDelegate, OverlayListDelegate, SelectableMarkerDelegate, CLLocationManagerDelegate {
    
    let MapService = MapDataService.shared
    
    let locationManager = CLLocationManager()
    
    let zoomLevel = 4.0
    
    var searchViewController: SearchViewController?
    var overlayViewController: OverlayListViewController?
    var selectedAnnotation: DefaultMarkerAnnotation?
    var cardSelection: CardSelection?
    var mapViewRef: MGLMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = self.readMBXAccessToken() {
            MGLAccountManager.accessToken = token
        } else {
            // Manually set token
            MGLAccountManager.accessToken = "MAPBOX_PUBLIC_ACCESS_TOKEN"
        }
        
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v12")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.setCenter(CLLocationCoordinate2D(latitude: 37.50957, longitude: 15.0657637), zoomLevel: self.zoomLevel, animated: false)
        
        MapService.fetchMapData() { _ in
            self.initializeSearchView()
            self.addGPSLocationButton()
            self.loadBottomSlideshow()
            let cardItems = self.MapService.getResultData()
            
            var points: [DefaultMarkerAnnotation] = []
            
            for card in cardItems! {
                let point = DefaultMarkerAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: card.latitude, longitude: card.longitude)
                point.title = "\(card.id)"
                points.append(point)
            }
            mapView.addAnnotations(points)
        }
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Request location permissions
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        self.mapViewRef = mapView
        view.addSubview(mapView)
        
        self.getCurrentUserLocation() { lat, lng in
            print("Current location: latitude", lat, "-- longitude:", lng)
            self.mapViewRef?.showsUserLocation = true
        } // Called to add marker if possible
    }
    
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            self.getCurrentUserLocation() { lat, lng in
                guard let mapView = self.mapViewRef else {
                    print("No mapview for user location")
                    return
                }
                mapView.showsUserLocation = true
                mapView.setCenter(CLLocationCoordinate2D(latitude: lat, longitude: lng), zoomLevel: self.zoomLevel, animated: true)
            }
        case .denied, .restricted:
            print("Location access denied/restricted")
            self.mapViewRef?.setCenter(CLLocationCoordinate2D(latitude: 37.50957, longitude: 15.0657637), zoomLevel: self.zoomLevel, animated: false) // Default to Catania latitude: 37.50957, longitude: 15.0657637
        case .notDetermined:
            print("Location access not determined")
            self.mapViewRef?.setCenter(CLLocationCoordinate2D(latitude: 37.50957, longitude: 15.0657637), zoomLevel: self.zoomLevel, animated: false) // Default to Catania latitude: 37.50957, longitude: 15.0657637
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        guard let location = locations.last else { return }
        print("location did change")
    }
    
    // SelectableMarkerDelegate
    public func selectMarker(byTitle title: String? = nil, byCoordinates coordinates: (latitude: Double, longitude: Double)? = nil) {
        guard let targetAnnotation = filterAnnotations(byTitle: title, byCoordinates: coordinates)?.first as? DefaultMarkerAnnotation else {
            print("No annotations found matching the provided criteria.")
            return
        }
        guard targetAnnotation != self.selectedAnnotation else {
            print("Already selected")
            return
        }
        updateSelectedMarker(target: targetAnnotation)
    }
    
    // MGLMapViewDelegate
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if annotation is UserLocationAnnotation {
            return createAnnotationImage(mapView, named: "user-location", reuseIdentifier: "user-location")
        } else if let marker = annotation as? DefaultMarkerAnnotation {
            let reuseIdentifier = marker.isSelected ? "selected-marker" : "default-marker"
            let imageName = marker.isSelected ? "selected-marker" : "default-marker"
            return createAnnotationImage(mapView, named: imageName, reuseIdentifier: reuseIdentifier, height: 55)
        }
        return nil
    }
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        updateSelectedMarker(target: annotation)
    }
    
    // OverlayListDelegate
    func dismissOverlay() {
        guard let overlayViewController = self.overlayViewController else {
            print("No overlay")
            return
        }
        searchViewController?.searchBar.resignFirstResponder()
        overlayViewController.view.removeFromSuperview()
        overlayViewController.removeFromParent()
        self.overlayViewController = nil
    }
    func presentOverlay() {
        guard self.overlayViewController == nil else {
            print("Overlay already created")
            return
        }
        overlayViewController = OverlayListViewController()
        overlayViewController?.overlayDelegate = self
        overlayViewController?.selectionDelegate = self
        overlayViewController?.searchValues = searchViewController!.searchValues
        
        addChild(overlayViewController!)
        view.addSubview(overlayViewController!.view)
        overlayViewController!.view.frame = view.bounds
        view.bringSubviewToFront(searchViewController!.view)
    }
    
    // MARK: Private
    private func loadBottomSlideshow() {
        let slideshowVC = SlideshowViewController()
        let cardSelection = CardSelection()
        slideshowVC.cardSelection = cardSelection
        slideshowVC.selectionDelegate = self
        self.cardSelection = cardSelection
        
        addChild(slideshowVC)
        slideshowVC.view.frame = CGRect(x: 0, y: view.frame.height - 275, width: view.frame.width, height: 300)
        view.addSubview(slideshowVC.view)
        slideshowVC.didMove(toParent: self)
        slideshowVC.view.backgroundColor = .clear
    }
    private func initializeSearchView() {
        self.searchViewController = SearchViewController()
        
        searchViewController!.overlayDelegate = self
        addChild(searchViewController!)
        searchViewController!.view.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 10, width: view.frame.width, height: 144)
        searchViewController!.view.transform = CGAffineTransform(translationX: -10, y: 0)
        view.addSubview(searchViewController!.view)
        searchViewController!.didMove(toParent: self)
    }
    private func addGPSLocationButton() {
        let gpsButton = UIButton(type: .custom)
        gpsButton.setImage(UIImage(named: "gps-location"), for: .normal)
        gpsButton.addTarget(self, action: #selector(gpsButtonTapped), for: .touchUpInside)
        
        gpsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gpsButton)
        
        // Set button constraints
        NSLayoutConstraint.activate([
            gpsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            gpsButton.topAnchor.constraint(equalTo: searchViewController!.view.bottomAnchor, constant: -75),
            gpsButton.widthAnchor.constraint(equalToConstant: 40),
            gpsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc func gpsButtonTapped() {
        print("GPS TAPPED")
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.getCurrentUserLocation() { lat, lng in
                self.mapViewRef?.setCenter(CLLocationCoordinate2D(latitude: lat, longitude: lng), zoomLevel: self.zoomLevel, animated: true)
                self.selectedAnnotation = nil
            }
            
        } else if status == .denied || status == .restricted {
            // Redirect to settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        } else {
            // Request permission
            locationManager.requestWhenInUseAuthorization()
        }
    }
    private func getCurrentUserLocation(completion: @escaping (CLLocationDegrees, CLLocationDegrees) -> Void) {
        let locationQueue = DispatchQueue(label: "locationQueue")
        locationQueue.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
                guard let coords = self.locationManager.location?.coordinate else {
                    return
                }
                DispatchQueue.main.async {
                    completion(coords.latitude, coords.longitude)
                }
            } else {
                print("Location services are not enabled")
            }
        }
    }
    private func removeSelectedMarker(target: MGLAnnotation) {
        guard let mapView = self.mapViewRef else { return }
        guard let selectedMarkerAnnotation = target as? DefaultMarkerAnnotation else { return }
        if selectedMarkerAnnotation.isSelected {
            mapView.removeAnnotation(selectedMarkerAnnotation)
            let defaultAnnotation = DefaultMarkerAnnotation()
            defaultAnnotation.coordinate = selectedMarkerAnnotation.coordinate
            defaultAnnotation.title = selectedMarkerAnnotation.title
            mapView.addAnnotation(defaultAnnotation)
        }
        self.selectedAnnotation = nil
    }
    private func updateSelectedMarker(target: MGLAnnotation) {
        guard let mapView = self.mapViewRef else { return }
        guard let defaultMarkerAnnotation = target as? DefaultMarkerAnnotation else { return }
        guard selectedAnnotation?.title != defaultMarkerAnnotation.title else {
            print("Already selected cannot update")
            return
        }
        MapService.setSelectedCard(byTitle: defaultMarkerAnnotation.title!)
        // If exists selected, unselect
        if let currentlySelected = self.selectedAnnotation {
            mapView.removeAnnotation(currentlySelected)
            let deselectedAnnotation = DefaultMarkerAnnotation()
            deselectedAnnotation.coordinate = currentlySelected.coordinate
            deselectedAnnotation.title = currentlySelected.title
            mapView.addAnnotation(deselectedAnnotation)
        }
        // Set new marker as selected
        mapView.removeAnnotation(defaultMarkerAnnotation)
        let selectedAnnotation = DefaultMarkerAnnotation()
        selectedAnnotation.isSelected = true
        selectedAnnotation.coordinate = defaultMarkerAnnotation.coordinate
        selectedAnnotation.title = defaultMarkerAnnotation.title
        print("update marker ", selectedAnnotation)
        mapView.addAnnotation(selectedAnnotation)
        // Set new selectedAnnotation
        self.selectedAnnotation = selectedAnnotation
        if let annotationTitle = selectedAnnotation.title,
           let numId = NumberFormatter().number(from: annotationTitle) {
            let coords = selectedAnnotation.coordinate
            let id = numId.intValue
            self.cardSelection?.selectCardID(withId: id)
            self.cardSelection?.selectCardCoords(latitude: coords.latitude, longitude: coords.longitude)
        }
        // Center to selected
        print(selectedAnnotation.coordinate)
        mapView.setCenter(selectedAnnotation.coordinate, zoomLevel: self.zoomLevel ,animated: true)
    }
    private func filterAnnotations(byTitle title: String? = nil, byCoordinates coordinates: (latitude: Double, longitude: Double)? = nil) -> [MGLAnnotation]? {
        guard title != nil || coordinates != nil else {
            print("Please provide at least one criterion to filter annotations.")
            return nil
        }
        guard let annotations = mapViewRef?.annotations else { return nil }
        
        return annotations.filter { annotation in
            if let title = title, let annotationTitle = annotation.title, annotationTitle == title {
                return true
            }
            if let coordinates = coordinates,
               annotation.coordinate.latitude == coordinates.latitude &&
                annotation.coordinate.longitude == coordinates.longitude {
                return true
            }
            return false
        }
    }
    private func createAnnotationImage(_ mapView: MGLMapView, named name: String, reuseIdentifier: String, height: Int = 40) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        if annotationImage == nil {
            var image = UIImage(named: name)!
            let size = CGSize(width: 40, height: height)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(origin: .zero, size: size))
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
        }
        return annotationImage
    }
    func readMBXAccessToken() -> String? {
        if let infoDictionary = Bundle.main.infoDictionary,
           let accessToken = infoDictionary["MBXAccessToken"] as? String {
            return accessToken
        } else {
            print("MBXAccessToken not found in Info.plist")
            return nil
        }
    }
    private func checkEquatableCoordinates(_ a: CLLocationCoordinate2D?, _ b: CLLocationCoordinate2D?) -> Bool {
        return a?.latitude == b?.latitude && a?.longitude == b?.longitude
    }
}

