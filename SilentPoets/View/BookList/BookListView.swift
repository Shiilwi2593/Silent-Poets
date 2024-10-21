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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(bookListVM.books, id: \.id) { book in
                        BookListCell(book: book, isTabBarShowing: $isTabBarShowing)
                    }
                    
                    if bookListVM.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    if bookListVM.hasMorePages {
                        Color.clear
                            .frame(height: 50)
                            .onAppear {
                                bookListVM.fetchBooks()
                            }
                    }
                }
                .padding()
            }
            .refreshable {
                await refreshBooks()
            }
            .onAppear {
                if bookListVM.books.isEmpty {
                    bookListVM.fetchBooks()
                }
                isTabBarShowing = true
            }
            .navigationTitle("Books")
        }
    }
    
    func refreshBooks() async {
        bookListVM.fetchBooks(isRefreshing: true)
    }
}

//#Preview {
//    BookListView()
//}


