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
    
    //SwiftData
    @Environment(\.modelContext) private var context
    @Query private var favorBooks: [FavorBook]
    @Query private var trackingBooks: [TrackingBook]
    
    //State
    @State private var arrFavorBooksId = [Int]()
    @State private var showLoadingView = true
    
    @State private var arrTrackingBooksId = [Int]()
    
    var rows: [GridItem] = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack{
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
                                if favorBooks.isEmpty{
                                    HStack {
                                        Spacer()
                                        Text("You're not favoriting any books yet.")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                        Spacer()
                                    }
                                    .frame(height: 240)
                                } else {
                                    ScrollView(.horizontal) {
                                        LazyHGrid(rows: rows) {
                                            ForEach(bookShelfVM.favBooks, id: \.id) { book in
                                                FavBookCell(book: book, isTabBarShowing: $isTabBarShowing)
                                                
                                                Divider()
                                            }
                                        }
                                    }
                                    .onAppear(){
                                        showLoadingView = false
                                    }
                                    .frame(height: 240)
                                }
                                
                                
                            }
                        }
                    
                    Section(header: Text("Reading list")
                        .offset(x: -20)
                        .fontWeight(.semibold)){
                            if showLoadingView {
                                HStack {
                                    Spacer()
                                    ProgressView("Loading reading list...")
                                        .font(.subheadline)
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Spacer()
                                }
                                .frame(height: 240)
                            } else {
                                ScrollView{
                                    LazyVStack{
                                        if trackingBooks.isEmpty{
                                            VStack(alignment: .center){
                                                Spacer()
                                                Text("You're not tracking any books yet.")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                                Spacer()
                                                
                                            }
                                            .frame(height: 90)
                                        } else {
                                            ForEach(bookShelfVM.trackBooks, id: \.id) { trackBook in
                                                let bookId = trackBook.id
                                                if let trackingBook = trackingBooks.first(where: { $0.bookId == bookId}) {
                                                    TrackingBookCell(trackBook: trackBook, trackingBook: trackingBook, isTabBarShowing: $isTabBarShowing)
                                                    
                                                    Divider()
                                                        .padding(.top, 12)
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                .onAppear(){
                                    showLoadingView = false
                                    isTabBarShowing = true
                                }
                                
                                
                            }
                            
                            
                        }
                    
                }
                
            }
            .navigationTitle("BookShelf")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if bookShelfVM.hasFetchedFav {
                    showLoadingView = true
                    bookShelfVM.hasFetchedFav = false
                }
                if bookShelfVM.hasFetchedTrack{
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


#Preview {
    BookShelfView(isTabBarShowing: .constant(true))
}

struct FavBookCell: View {
    let book: Book
    @Binding var isTabBarShowing: Bool
    
    
    var body: some View {
        NavigationLink(destination: DetailBookView(book: book, isTabBarShowing: $isTabBarShowing)) {
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
                    .foregroundStyle(.black)
                
                Text("by \(book.authors.first?.name ?? "Unknown Author")")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
            }
            .frame(width: 140)
            .padding()
        }
        
    }
}

struct TrackingBookCell: View {
    let trackBook: Book
    let trackingBook: TrackingBook
    @Binding var isTabBarShowing: Bool
    let bookListVM = BookListViewModel.shared
    
    var body: some View {
        NavigationLink(destination: DetailBookView(book: trackBook, isTabBarShowing: $isTabBarShowing)) {
            HStack{
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
                
                VStack(alignment: .leading){
                    Text(trackBook.title)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                    Text("by \(trackBook.authors.first?.name ?? "Unknown Author")")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    VStack(alignment: .trailing){
                        ProgressView(value: trackingBook.progress, total: 100)
                        Text("\(String(describing: trackingBook.progress)) of 100%")
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
