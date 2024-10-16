//
//  BookShelf.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 16/10/24.
//

import Foundation
import SwiftData

@Model
class FavorBook{
    var favorBook: Book
    
    init(book: Book) {
        self.favorBook = book
    }
}
