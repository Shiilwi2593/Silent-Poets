//
//  File.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import Foundation

struct Book: Codable {
    let id: Int
    let title: String
    let authors: [Author]
    let translators: [String?] // Assuming translators are an array of optional strings
    let subjects, bookshelves, languages: [String]
    let copyright: Bool
    let mediaType: String
    let formats: Formats
    let downloadCount: Int

    struct Author: Codable {
        let name: String
        let birthYear, deathYear: Int?
    }

    struct Formats: Codable {
        let textHTML: String?
        let applicationEpubZip: String?
        let applicationXMobipocketEbook: String?
        let applicationRDFXML: String?
        let imageJPEG: String?
        let textPlainCharsetUsASCII: String?
        let applicationOctetStream: String?
    }
}

