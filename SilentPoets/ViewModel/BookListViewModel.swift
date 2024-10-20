//
//  BookViewModel.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import Foundation

class BookListViewModel: ObservableObject {
    static let shared = BookListViewModel()

    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    
    private var currentPage = 1
    private let pageSize = 32
    private var nextPageURL: String?
    
    var onBookAdded: (() -> Void)?
    
    func fetchBooks(isRefreshing: Bool = false) {
        if isRefreshing {
            resetPagination()
        }
        
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        
        let urlString = nextPageURL ?? "https://gutendex.com/books/?page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 100
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { DispatchQueue.main.async { self.isLoading = false } }
            
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("Invalid data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.nextPageURL = json["next"] as? String
                        self.hasMorePages = self.nextPageURL != nil
                    }
                    
                    if let results = json["results"] as? [[String: Any]] {
                        let newBooks = results.compactMap { self.createBook(from: $0) }
                        DispatchQueue.main.async {
                            if isRefreshing {
                                self.books = newBooks
                            } else {
                                self.books.append(contentsOf: newBooks)
                            }
                            self.currentPage += 1
                            self.onBookAdded?()
                        }
                    }
                } else {
                    print("Invalid JSON structure")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func resetPagination() {
        books = []
        currentPage = 1
        nextPageURL = nil
        hasMorePages = true
    }
    
    
    private func createBook(from dictionary: [String: Any]) -> Book? {
        guard let id = dictionary["id"] as? Int,
              let title = dictionary["title"] as? String,
              let authorsArray = dictionary["authors"] as? [[String: Any]],
              let subjects = dictionary["subjects"] as? [String],
              let bookshelves = dictionary["bookshelves"] as? [String],
              let languages = dictionary["languages"] as? [String],
              let copyright = dictionary["copyright"] as? Bool,
              let mediaType = dictionary["media_type"] as? String,
              let formats = dictionary["formats"] as? [String: Any],
              let downloadCount = dictionary["download_count"] as? Int else {
            return nil
        }
        
        // Create authors array
        let authors = authorsArray.compactMap { authorDict -> Book.Author? in
            guard let name = authorDict["name"] as? String,
                  let birthYear = authorDict["birth_year"] as? Int?,
                  let deathYear = authorDict["death_year"] as? Int? else {
                return nil
            }
            return Book.Author(name: name, birthYear: birthYear, deathYear: deathYear)
        }
        
        let format = Book.Formats(
            textHTML: formats["text/html"] as? String,
            applicationEpubZip: formats["application/epub+zip"] as? String,
            applicationXMobipocketEbook: formats["application/x-mobipocket-ebook"] as? String,
            applicationRDFXML: formats["application/rdf+xml"] as? String,
            imageJPEG: formats["image/jpeg"] as? String,
            textPlainCharsetUsASCII: formats["text/plain; charset=us-ascii"] as? String,
            applicationOctetStream: formats["application/octet-stream"] as? String
        )
        
        return Book(id: id,
                    title: title,
                    authors: authors,
                    translators: [],
                    subjects: subjects,
                    bookshelves: bookshelves,
                    languages: languages,
                    copyright: copyright,
                    mediaType: mediaType,
                    formats: format,
                    downloadCount: downloadCount)
    }
}

