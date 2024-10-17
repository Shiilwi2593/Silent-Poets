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
        VStack {
            List {
                Section(header: Text("Favourite Books")
                    .offset(x: -20)
                    .fontWeight(.semibold)) {
                        if showLoadingView {
                            HStack {
                                Spacer()
                                ProgressView("Loading favorite books...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                            .frame(height: 240)
                        } else if bookShelfVM.hasFetched {
                            ScrollView(.horizontal) {
                                LazyHGrid(rows: rows) {
                                    ForEach(bookShelfVM.favBooks, id: \.id) { book in
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
                                            
                                            Text("by \(book.authors.first?.name ?? "Unknown Author")")
                                                .font(.footnote)
                                                .fontWeight(.semibold)
                                                .lineLimit(2)
                                                .foregroundStyle(.gray)
                                        }
                                        .frame(width: 130)
                                        .padding()
                                        
                                        Divider()
                                    }
                                }
                            }
                            .frame(height: 240)
                        }
                    }
                
                Section(header: Text("Reading list")
                    .offset(x: -20)
                    .fontWeight(.semibold)){
                        if showLoadingView {
                            HStack {
                                Spacer()
                                ProgressView("Loading reading list...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                            .frame(height: 240)
                        } else if bookShelfVM.hasFetched{
                            ScrollView{
                                LazyVStack{
                                    ForEach(bookShelfVM.trackBooks, id: \.id) { book in
                                            HStack{
                                                AsyncImage(url: URL(string: book.formats.imageJPEG ?? "https://static.wikia.nocookie.net/gijoe/images/b/bf/Default_book_cover.jpg/revision/latest?cb=20240508080922")) { image in
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
                                                    Text(book.title)
                                                        .font(.system(size: 17))
                                                        .fontWeight(.semibold)
                                                        .lineLimit(2)
                                                    Text("by \(book.authors.first?.name ?? "Unknown Author")")
                                                        .font(.footnote)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.gray)
                                                    
                                                    VStack(alignment: .trailing){
                                                        ProgressView(value: 50, total: 100)
                                                        Text("50 of 100%")
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
                                            
                                            Divider()
                                                .padding(.top, 12)
                                        }
                                    }
                                }
                            
                          
                        }
                        
                        
                    }
            }
            .navigationTitle("BookShelf")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLoadingView = false
                }
            }
        }
        
    }
    
}



//
//                    Section(header: Text("Reading Books")
//                        .font(.subheadline)
//                        .offset(x: -20)
//                        .fontWeight(.semibold)) {
//                        LazyVStack{
//                            ForEach(favouriteBooks){book in
//                                VStack{
//                                    HStack{
//                                        AsyncImage(url: URL(string: book.image)) { image in
//                                            image
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 90, height: 130)
//                                                .clipped()
//                                                .shadow(radius: 10, x: 0, y: 10)
//                                        } placeholder: {
//                                            ProgressView()
//                                        }
//
//                                        VStack(alignment: .leading){
//                                            Text(book.title)
//                                                .font(.system(size: 19))
//                                                .fontWeight(.bold)
//                                                .lineLimit(2)
//                                            Text(book.author)
//                                                .font(.subheadline)
//                                                .fontWeight(.semibold)
//                                                .foregroundStyle(.gray)
//                                            VStack(alignment: .trailing){
//                                                ProgressView(value: 50, total: 100)
//                                                Text("50% of 100%")
//                                                    .font(.footnote)
//                                                    .foregroundStyle(.gray)
//                                                    .fontWeight(.semibold)
//                                            }
//
//
//                                            Spacer()
//                                        }
//                                        .padding(.top, 12)
//                                        .padding(.leading, 6)
//
//                                        Spacer()
//                                    }
//                                    .padding(.top, 10)
//
//                                    Divider()
//                                        .padding(.top, 12)
//                                }
//
//                            }
//                        }
//                    }
//


//    #Preview {
//        BookShelfView(isTabBarShowing: .constant(true))
//    }

//    var favouriteBooks: [FavouriteBook] = [
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//        FavouriteBook(
//            title: "Romeo and Juliet",
//            image: "https://www.gutenberg.org/cache/epub/145/pg145.cover.medium.jpg",
//            author: "by Shakespeare, William"
//        ),
//    ]
//
//struct FavouriteBook: Identifiable {
//    var id = UUID()
//    var title: String
//    var image: String
//    var author: String
//}


//                            Section(header: Text("Reading Books")
//                                .font(.subheadline)
//                                .offset(x: -20)
//                                .fontWeight(.semibold)) {
//                                LazyVStack{
//                                    ForEach(favouriteBooks){book in
//                                        VStack{
//                                            HStack{
//                                                AsyncImage(url: URL(string: book.image)) { image in
//                                                    image
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(width: 90, height: 130)
//                                                        .clipped()
//                                                        .shadow(radius: 10, x: 0, y: 10)
//                                                } placeholder: {
//                                                    ProgressView()
//                                                }
//
//                                                VStack(alignment: .leading){
//                                                    Text(book.title)
//                                                        .font(.system(size: 19))
//                                                        .fontWeight(.bold)
//                                                        .lineLimit(2)
//                                                    Text(book.author)
//                                                        .font(.subheadline)
//                                                        .fontWeight(.semibold)
//                                                        .foregroundStyle(.gray)
//                                                    VStack(alignment: .trailing){
//                                                        ProgressView(value: 50, total: 100)
//                                                        Text("50% of 100%")
//                                                            .font(.footnote)
//                                                            .foregroundStyle(.gray)
//                                                            .fontWeight(.semibold)
//                                                    }
//
//
//                                                    Spacer()
//                                                }
//                                                .padding(.top, 12)
//                                                .padding(.leading, 6)
//
//                                                Spacer()
//                                            }
//                                            .padding(.top, 10)
//
//                                            Divider()
//                                                .padding(.top, 12)
//                                        }
//
//                                    }
//                                }
//                            }
