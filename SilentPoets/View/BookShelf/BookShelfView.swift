//
//  BookShelfView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI
import SwiftData

struct BookShelfView: View {
    @Binding var isTabBarShowing: Bool
    
    @StateObject private var bookShelfVM = BookShelfViewModel.shared
    @Environment(\.colorScheme) private var colorScheme
    
    //SwiftData
    @Environment(\.modelContext) private var context
    @Query private var favorBooks: [FavorBook]
    @Query private var trackingBooks: [TrackingBook]
    
    //State
    @State private var arrFavorBooksId = [Int]()
    @State private var showLoadingView = true
    @State private var arrTrackingBooksId = [Int]()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Favourite Books")
                        .offset(x: -20)
                        .fontWeight(.semibold)) {
                            if showLoadingView {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading favorite books...")
                                        .font(.subheadline)
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Spacer()
                                }
                                .frame(height: 240)
                            } else {
                                if favorBooks.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("You're not favoriting any books yet.")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                        Spacer()
                                    }
                                    .frame(height: 240)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(bookShelfVM.favBooks, id: \.id) { book in
                                                FavBookCell(book: book, isTabBarShowing: $isTabBarShowing)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(height: 240)
                                }
                            }
                        }
                    
                    Section(header: Text("Reading Books")
                        .offset(x: -20)
                        .fontWeight(.semibold)) {
                            if showLoadingView {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading reading books...")
                                        .font(.subheadline)
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Spacer()
                                }
                                .frame(height: 240)
                            } else {
                                ScrollView {
                                    LazyVStack {
                                        let readingBooks = trackingBooks.filter { $0.progress < 100 }
                                        if readingBooks.isEmpty {
                                            Text("You're not currently reading any books.")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                                .frame(height: 90)
                                        } else {
                                            ForEach(readingBooks, id: \.bookId) { trackingBook in
                                                if let book = bookShelfVM.trackBooks.first(where: { $0.id == trackingBook.bookId }) {
                                                    TrackingBookCell(trackBook: book, trackingBook: trackingBook, isTabBarShowing: $isTabBarShowing)
                                                    Divider().padding(.top, 12)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    
                    Section(header: Text("Finished Books")
                        .offset(x: -20)
                        .fontWeight(.semibold)) {
                            if showLoadingView {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading finished books...")
                                        .font(.subheadline)
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Spacer()
                                }
                                .frame(height: 240)
                            } else {
                                ScrollView {
                                    LazyVStack {
                                        let finishedBooks = trackingBooks.filter { $0.progress == 100 }
                                        if finishedBooks.isEmpty {
                                            Text("You haven't finished any books yet.")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                                .frame(height: 90)
                                        } else {
                                            ForEach(finishedBooks, id: \.bookId) { trackingBook in
                                                if let book = bookShelfVM.trackBooks.first(where: { $0.id == trackingBook.bookId }) {
                                                    TrackingBookCell(trackBook: book, trackingBook: trackingBook, isTabBarShowing: $isTabBarShowing)
                                                    Divider().padding(.top, 12)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
            }
            .navigationTitle("BookShelf")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                isTabBarShowing = true
                if bookShelfVM.hasFetchedFav {
                    showLoadingView = true
                    bookShelfVM.hasFetchedFav = false
                }
                if bookShelfVM.hasFetchedTrack {
                    showLoadingView = true
                    bookShelfVM.hasFetchedTrack = false
                }
                
                print(favorBooks)
                
                arrFavorBooksId.removeAll()
                arrTrackingBooksId.removeAll()
                
                bookShelfVM.favBooks.removeAll()
                bookShelfVM.trackBooks.removeAll()
                
                arrFavorBooksId = favorBooks.map { $0.bookId }
                arrTrackingBooksId = trackingBooks.map { $0.bookId }
                
                let favIdString = arrFavorBooksId.map { String($0) }.joined(separator: ",")
                let trackingIdString = arrTrackingBooksId.map { String($0) }.joined(separator: ",")
                
                bookShelfVM.fetchFavouriteBooks(favIdString: favIdString)
                bookShelfVM.fetchTrackingBooks(trackingIdString: trackingIdString)
            }
            .onReceive(bookShelfVM.$hasFetchedFav) { hasFetched in
                if hasFetched {
                    showLoadingView = false
                }
            }
            .onReceive(bookShelfVM.$hasFetchedTrack) { hasFetched in
                if hasFetched {
                    showLoadingView = false
                }
            }
        }
    }
}

struct FavBookCell: View {
    let book: Book
    @Binding var isTabBarShowing: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationLink(destination: DetailBookView(book: book, isTabBarShowing: $isTabBarShowing)) {
            HStack {
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: book.formats.imageJPEG ?? "https://static.wikia.nocookie.net/gijoe/images/b/bf/Default_book_cover.jpg/revision/latest?cb=20240508080922")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 160)
                            .clipped()
                            .shadow(radius: 10, x: -5, y: 5)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("by \(book.authors.first?.name ?? "Unknown Author")")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(.gray)
                }
                .frame(width: 140)
                .padding()
            }
            
            Divider()
                .padding()
        }
    }
}

struct TrackingBookCell: View {
    let trackBook: Book
    let trackingBook: TrackingBook
    @Binding var isTabBarShowing: Bool
    @Environment(\.colorScheme) private var colorScheme
    let bookListVM = BookListViewModel.shared
    
    var body: some View {
        NavigationLink(destination: DetailBookView(book: trackBook, isTabBarShowing: $isTabBarShowing)) {
            ZStack(alignment: .bottomTrailing) {
                if trackingBook.progress == 100 {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.green)
                }
                HStack {
                    AsyncImage(url: URL(string: trackBook.formats.imageJPEG ?? "https://static.wikia.nocookie.net/gijoe/images/b/bf/Default_book_cover.jpg/revision/latest?cb=20240508080922")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 130)
                            .clipped()
                            .shadow(radius: 10, x: 0, y: 10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    VStack(alignment: .leading) {
                        Text(trackBook.title)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        Text("by \(trackBook.authors.first?.name ?? "Unknown Author")")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .trailing) {
                            ProgressView(value: trackingBook.progress, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: trackingBook.progress == 100 ? .green : .blue))
                            Text(String(format: "%.1f of 100%%", trackingBook.progress))
                                .font(.system(size: 10))
                                .font(.footnote)
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.leading, 6)
                    
                    Spacer()
                }
                .padding(.top, 12)
            }
        }
    }
}

#Preview {
    BookShelfView(isTabBarShowing: .constant(true))
}
