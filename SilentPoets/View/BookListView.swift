//
//  BookListView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct BookListView: View {
    
    @StateObject private var bookListVM = BookListViewModel()
    
    let columns: [GridItem] = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView{
                    LazyVGrid(columns: columns) {
                        ForEach(bookListVM.books, id: \.id) { book in
                            BookListCell(book: book)
                        }
                    }
                    .padding()
                    .onAppear {
                        bookListVM.fetchBooks()
                    }
                
                }
                
            }
            .navigationTitle("Books")
        }
    }
}

#Preview {
    BookListView()
}

struct BookListCell: View {
    var book: Book

    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: book.formats.imageJPEG!)) { image in
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
                    Text(book.title)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.top, 12)
                        .lineLimit(2)

                    if let author = book.authors.first {
                        Text(author.name)
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
    }
}
