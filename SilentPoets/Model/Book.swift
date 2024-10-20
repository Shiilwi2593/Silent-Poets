//
//  File.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import Foundation
import SwiftData

struct Book: Identifiable, Equatable, Codable {
    let id: Int
    let title: String
    let authors: [Author]
    let translators: [String?]
    let subjects, bookshelves, languages: [String]
    let copyright: Bool
    let mediaType: String
    let formats: Formats
    let downloadCount: Int

    struct Author: Codable {
        let name: String
        let birthYear, deathYear: Int?
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
         return lhs.id == rhs.id
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

