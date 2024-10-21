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
    @State private var isDarkMode = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
   
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Circle()
                        .fill(isDarkMode ? .darkTheme : .white)
                        .frame(width: 50, height: 50)
                        .shadow(color: isDarkMode ? .gray : .black, radius: 2, x: 0, y: 0)
                    
                        .overlay {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.title)
                                .foregroundColor(isDarkMode ? .yellow : .blue)
                                .padding()
                        }
                }
                .zIndex(1)
                .padding(.bottom, 60)
                .padding(.trailing, 15)
            VStack {
                if selectedIndex == 0 {
                    BookListView(isTabBarShowing: $isTabBarShowing)
                } else if selectedIndex == 1 {
                    SearchView(isTabBarShowing: $isTabBarShowing)
                } else if selectedIndex == 2 {
                    BookShelfView(isTabBarShowing: $isTabBarShowing)
                }

                Spacer()

                if isTabBarShowing {
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
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .zIndex(0)

        }
        
    }
}

#Preview {
    MainView()
}
