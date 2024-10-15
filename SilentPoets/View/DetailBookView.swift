//
//  DetailBookView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 15/10/24.
//

import SwiftUI


struct DetailBookView: View {
    
    var book: Book
    @State private var isSaved: Bool = false
    @Binding var isTabBarShowing: Bool

    
    var body: some View {
        let url = URL(string: book.formats.imageJPEG!)
        
        ZStack {
            Color.white
            ScrollView{
                VStack{
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 140)
                            .shadow(radius: 10, x: 0, y: 10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text(book.title)
                        .font(.system(size: 20, weight: .semibold))
                        .shadow(radius: 10, x: 0, y: 10)
                        .padding(.top, 5)
                        .padding([.leading, .trailing], 10)
                    
                    if let author = book.authors.first {
                        Text("by \(author.name)")
                            .font(.subheadline)
                            .padding(.top, -3)
                            .foregroundStyle(.gray)
                    }
                    
                    StatsView(book: book)
                    
                    VStack(alignment: .leading){
                        if !book.subjects.isEmpty {
                            Text("Subjects:")
                                .font(.headline)
                                .padding(.top, 8)
                                .padding(.leading, 10)
                            ForEach(book.subjects, id: \.self) { subject in
                                Text("✼ \(subject)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 14)
                            }
                        }
                    }
                    NavigationLink(destination: BookReadingView(urlString: book.formats.textHTML!)) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.white)
                            Text("Start reading")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                        .frame(width: 280, height: 50)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .padding(.top, 20)
                    }
                    
                    
                    
                    
                    Spacer()
                }
            }
            .onAppear(){
                isTabBarShowing = false
            }
            
        }
        .navigationTitle("\(book.title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSaved.toggle()
                    }                } label: {
                        withAnimation {
                            Image(systemName: "bookmark.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20) 
                                .foregroundStyle(isSaved ? .yellow : .black.opacity(0.6))
                                .scaleEffect(isSaved ? 1.3 : 1.0)
                            
                        }
                    }
                
            }
        }
    }
}




#Preview {
    DetailBookView(book: Book(id: 84,
                              title: "Frankenstein; Or, The Modern Prometheus",
                              authors: [Book.Author(name: "Shelley, Mary Wollstonecraft",
                                                    birthYear: 1797,
                                                    deathYear: 1851)],
                              translators: [],
                              subjects: [ "Frankenstein's monster (Fictitious character) -- Fiction",
                                          "Frankenstein, Victor (Fictitious character) -- Fiction",
                                          "Gothic fiction",
                                          "Horror tales",
                                          "Monsters -- Fiction",
                                          "Science fiction",
                                          "Scientists -- Fiction"],
                              bookshelves: [
                                "Browsing: Culture/Civilization/Society",
                                "Browsing: Fiction",
                                "Browsing: Gender & Sexuality Studies",
                                "Browsing: Literature",
                                "Browsing: Science-Fiction & Fantasy",
                                "Gothic Fiction",
                                "Movie Books",
                                "Precursors of Science Fiction",
                                "Science Fiction by Women"
                              ],
                              languages: ["en"],
                              copyright: false,
                              mediaType: "Text",
                              formats: Book.Formats(textHTML: "https://www.gutenberg.org/ebooks/84.html.images",
                                                    applicationEpubZip: "https://www.gutenberg.org/ebooks/84.epub3.images",
                                                    applicationXMobipocketEbook: "https://www.gutenberg.org/ebooks/84.kf8.images",
                                                    applicationRDFXML: "https://www.gutenberg.org/ebooks/84.rdf",
                                                    imageJPEG: "https://www.gutenberg.org/cache/epub/84/pg84.cover.medium.jpg",
                                                    textPlainCharsetUsASCII: "https://www.gutenberg.org/ebooks/84.txt.utf-8",
                                                    applicationOctetStream: "https://www.gutenberg.org/cache/epub/84/pg84-h.zip"),
                              downloadCount: 78467), isTabBarShowing: .constant(false))
}

struct StatsView: View {
    var book: Book
    
    var body: some View {
        HStack(spacing: 20){
            HStack(spacing: 2) {
                Image(systemName: "tray.and.arrow.down.fill")
                    .foregroundColor(.green)
                Text("\(book.downloadCount)")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
            .frame(width: 90, height: 60)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            VStack{
                Text("Languages")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                
                Text("\(book.languages.joined(separator: ", "))")
                    .font(.headline)
            }
            .frame(width: 90, height: 55)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
