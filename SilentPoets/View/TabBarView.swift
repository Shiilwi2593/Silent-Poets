//
//  TabBarView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectionIndex: Int
    @Binding var isTabBarShowing: Bool
    
    let tabbarImage: [String] = ["tray.full.fill", "magnifyingglass", "books.vertical.fill"]
    let tabbarTitle: [String] = ["Books", "Search", "Bookshelf"]
    
    var body: some View {

        HStack{
            ForEach(0..<3){ index in
                Button {
                    selectionIndex = index
                } label: {
                    Spacer()
                    VStack{
                        Image(systemName: tabbarImage[index])
                            .font(.system(size: 20))
                            .frame(width: 20,height: 20)
                            .foregroundColor(selectionIndex == index ? Color.black : .black.opacity(0.7))
                            .scaledToFit()
                        Text (tabbarTitle[index])
                            .padding(.top,2)
                            .font(.system(size: 12))
                            .foregroundColor(selectionIndex == index ? Color.black : .black.opacity(0.7))
                    }
                    Spacer()
                }
                
                
            }
        }
    }
}
//
//#Preview {
//    TabBarView()
//}
