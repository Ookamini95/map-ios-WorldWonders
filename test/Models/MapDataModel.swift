//
//  MapDataModel.swift
//  test
//
//  Created by Enrico on 01/08/24.
//

import Foundation

// MARK: - Main Response
struct ApiResponse: Codable {
    let count: Int
    let previous: String?
    let results: [CardItem]
    let next: String?
}

// MARK: - Result Item
struct CardItem: Codable, Identifiable {
    let id: Int
    let name: String
    let generalInfo: String
    let address: String
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let coverMobileThumbnail: String
    let cover: String
    let favourite: Bool
    let mustSee: Bool
    let audioMedias: [AudioMedia]
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case id, name
        case generalInfo = "general_info"
        case address, latitude, longitude, elevation
        case coverMobileThumbnail = "cover_mobile_thumbnail"
        case cover, favourite
        case mustSee = "must_see"
        case audioMedias = "audio_medias"
        case categories
    }
}

// MARK: - Audio Media
struct AudioMedia: Codable {
    let id: Int
    let mediaFile: String
    let chapter: String
    let mediaCategory: MediaCategory

    enum CodingKeys: String, CodingKey {
        case id
        case mediaFile = "media_file"
        case chapter
        case mediaCategory = "media_category"
    }
}

// MARK: - Media Category
struct MediaCategory: Codable {
    let id: Int
    let name: String
    let slug: String
    let cover: String
    let color: String
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let icon: String?
}
