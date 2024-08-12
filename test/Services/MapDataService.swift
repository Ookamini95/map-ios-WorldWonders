//
//  MapDataService.swift
//  test
//
//  Created by Enrico on 01/08/24.
//

import Foundation
import Alamofire
import Mapbox

class MapDataService {
    static let shared = MapDataService()
    
    var selectedCardItem: CardItem?
    private var mapData: [String: [CardItem]?] = [:]
    
    func fetchMapData(completion: ((Result<Void, Error>) -> Void)? = nil) {
            let url = "url"
            let token = "token"
            let language = "it"
            
            let headers: HTTPHeaders = [
                "Accept-Language": language,
                "Authorization": "Bearer \(token)"
            ]
        
            AF.request(url, headers: headers).responseData { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let apiResponse = try decoder.decode(ApiResponse.self, from: data)
                        self.mapData["data"] = apiResponse.results
                        completion?(.success(()))
                    } catch {
                        completion?(.failure(error))
                    }
                case .failure(let error):
                    print("Something bad happened: ", error)
                    // Load Mock data
                    loadMockData()
                    completion?(.failure(error))
                }
            }
    }
    
    func loadMockData() {
        let data = self.readMockApiJson()
        self.mapData["data"] = data?.results
    }
    func setSelectedCard(byTitle title: String?) {
        guard let data = mapData["data"], let title = title else {
            print("Bad data, unable to set a card")
            return
        }
        print("Setting ", title)
        selectedCardItem = data?.first(where: { "\($0.id)" == title })
    }
    func getResultData() -> [CardItem]? {
        return mapData["data"] ?? nil
    }
    private func readMockApiJson() -> ApiResponse? {
        // Locate the file in the app bundle
        if let filePath = Bundle.main.path(forResource: "mock.api", ofType: "json") {
            do {
                // Read the contents of the file
                let fileContents = try Data(contentsOf: URL(fileURLWithPath: filePath))
                // Decode the JSON data
                let decoder = JSONDecoder()
                let res = try decoder.decode(ApiResponse.self, from: fileContents)
                return res
            } catch {
                print("Error reading or parsing file: \(error.localizedDescription)")
            }
        } else {
            print("File not found")
        }
        return nil
    }
}
