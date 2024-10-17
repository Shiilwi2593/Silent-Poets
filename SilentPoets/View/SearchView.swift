//
//  SearchView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//
import SwiftUI

struct SearchView: View {
    @Binding var isTabBarShowing: Bool
    @State var searchKeyword: String = ""
    @State var isSearchSubmitted: Bool = false
    
    @StateObject var searchVM = SearchViewModel.shared
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                SearchBar(searchKeyword: $searchKeyword, isSearchSubmitted: $isSearchSubmitted)
                    .onSubmit {
                        searchVM.fetchSearchResult(keyword: searchKeyword)
                        isSearchSubmitted = true
                    }
             
                
                Text("Recent Searches")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding()
                Spacer()
                    .frame(height: 80)
                
                Text("Search Results")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding()

                if isSearchSubmitted {
                    ScrollView{
                        if searchVM.isLoading{
                            ProgressView()
                                .padding()
                        } else {
                            if searchVM.searchList.isEmpty && !searchKeyword.isEmpty {
                                HStack{
                                    Spacer()
                                    Text("No results found for \"\(searchKeyword)\"")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding()
                                    Spacer()
                                }
                                
                            } else {
                                Grid {
                                    ForEach(searchVM.searchList, id: \.id) { book in
                                        BookListCell(book: book, isTabBarShowing: $isTabBarShowing)
                                    }
                                }
                                .offset(y: -25)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                isTabBarShowing = true
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
 
       
    }
}

#Preview {
    SearchView(isTabBarShowing: .constant(true))
}

struct SearchBar: View {
    @Binding var searchKeyword: String
    @Binding var isSearchSubmitted: Bool

    
    var body: some View {
        TextField("Search by Title, Author, Keyword", text: $searchKeyword)
            .padding(12)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if !searchKeyword.isEmpty {
                        Button(action: {
                            searchKeyword = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .onChange(of: searchKeyword) { newValue, oldValue in
                isSearchSubmitted = false
            }
            .padding(.horizontal, 15)
    }
}
