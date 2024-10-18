//
//  BookListView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct BookListView: View {
    
    @StateObject private var bookListVM = BookListViewModel.shared
    @Binding var isTabBarShowing: Bool
    
    let columns: [GridItem] = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView{
                    if bookListVM.books.count == 0{
                        ProgressView()
                    } else {
                        Grid{
                            ForEach(bookListVM.books, id: \.id) { book in
                                BookListCell(book: book, isTabBarShowing: $isTabBarShowing)
                            }
                        }
                        .padding()
                        
                        
                    }
                    
                }
                .onAppear {
                    bookListVM.fetchBooks()
                    isTabBarShowing = true
                    
                }
                
            }
            
            
            .navigationTitle("Books")
        }
    }
}

//#Preview {
//    BookListView()
//}

struct BookListCell: View {
    var book: Book
    @Binding var isTabBarShowing: Bool
    
    
    var body: some View {
        NavigationLink(destination: DetailBookView(book: book, isTabBarShowing: $isTabBarShowing)) {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: book.formats.imageJPEG ?? "https://static.wikia.nocookie.net/gijoe/images/b/bf/Default_book_cover.jpg/revision/latest?cb=20240508080922")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 150)
                            .clipped()
                            .shadow(radius: 10, x: -10, y: 20)
                            .offset(x: -10)
                    } placeholder: {
                         ProgressView()
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 6) {
                        let titleTrimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\u{200B}\u{FEFF}"))
                        
                        Text(titleTrimmed)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 12)
                            .lineLimit(2)
                            .foregroundStyle(.black)
                        
                        
                        if let author = book.authors.first {
                            Text("by \(author.name)")
                                .font(.footnote)
                                .foregroundStyle(Color(.systemGray))
                        }
                        
                        HStack(spacing: 3) {
                            Image(systemName: "tray.and.arrow.down.fill")
                                .foregroundStyle(.blue)
                            
                            Text("\(book.downloadCount)")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                                .padding(.top, 4)
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .listRowSeparator(.visible)
                .padding()
                
                Divider()
                    .padding([.leading, .trailing], 12)
            }
            .onAppear(){
                isTabBarShowing = true
            }
        }
        
    }
}

