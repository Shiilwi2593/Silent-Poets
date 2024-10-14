//
//  BookViewModel.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//
import Foundation

class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    
    var onBookAdded: (() -> Void)?
    
    func fetchBooks() {
        guard let url = URL(string: "https://gutendex.com/books/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 100

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(response!)")
                return
            }

            guard let data = data else {
                print("Invalid data")
                return
            }

            do {
                // Parsing the JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    
                    // Creating Book instances from results
                    for bookDict in results {
                        if let book = self.createBook(from: bookDict) {
                            DispatchQueue.main.async {
                                self.books.append(book)
                            }
                            
                        }
                    }
                    self.onBookAdded?() 

                    
                } else {
                    print("Invalid JSON structure")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    // Helper method to create a Book from a dictionary
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
                    translators: [], // Assuming empty for now, you can handle it if needed
                    subjects: subjects,
                    bookshelves: bookshelves,
                    languages: languages,
                    copyright: copyright,
                    mediaType: mediaType,
                    formats: format,
                    downloadCount: downloadCount)
    }
}

