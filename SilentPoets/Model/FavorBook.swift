//
//  BookShelf.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 16/10/24.
//

import Foundation
import SwiftData

@Model
class FavorBook: Identifiable {
    var id: String
    var bookId: Int

    init(bookId: Int) {
        self.bookId = bookId
        self.id = UUID().uuidString
    }
}
