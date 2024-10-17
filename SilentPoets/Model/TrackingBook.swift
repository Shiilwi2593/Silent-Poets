//
//  TrackingBook.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 17/10/24.
//

import Foundation
import SwiftData

@Model
class TrackingBook: Identifiable {
    var bookId: Int
    var progress: Double
    var createAt: Date
    var status: Status

    enum Status: String, Codable {
        case reading, finished
    }
    
    init(bookId: Int, createAt: Date, status: Status = .reading) {
        self.bookId = bookId
        self.progress = 0
        self.createAt = createAt
        self.status = .reading
    }
}
