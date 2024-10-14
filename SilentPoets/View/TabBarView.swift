//
//  TabBarView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView{
            BookListView()
                .tabItem {
                    Image(systemName: "tray.full.fill")
                    Text("Books")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            BookShelfView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Bookshelf")
                }
        }
            
    }
}
//
//#Preview {
//    TabBarView()
//}
