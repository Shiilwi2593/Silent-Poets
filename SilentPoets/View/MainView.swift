//
//  MainView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 15/10/24.
//

import SwiftUI

struct MainView: View {
    @State var selectedIndex = 0
    @State var isTabBarShowing = true
    
    var body: some View {
        VStack{
            if selectedIndex == 0 {
                    BookListView(isTabBarShowing: $isTabBarShowing)
                } else if selectedIndex == 1 {
                    SearchView(isTabBarShowing: $isTabBarShowing)
                } else if selectedIndex == 2 {
                    BookShelfView(isTabBarShowing: $isTabBarShowing)
                }
            Spacer()
            if isTabBarShowing{
                withAnimation(.easeInOut) {
                    TabBarView(selectionIndex: $selectedIndex, isTabBarShowing: $isTabBarShowing)
                }
            } else {
                withAnimation(.easeInOut) {
                    TabBarView(selectionIndex: $selectedIndex, isTabBarShowing: $isTabBarShowing)
                        .hidden()
                }
               
            }
            
        }
    }
}

#Preview {
    MainView()
}
