//
//  BookShelfView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct BookShelfView: View {
    @Binding var isTabBarShowing: Bool

    var body: some View {
        Text("BookShelf")
    }
}

#Preview {
    BookShelfView(isTabBarShowing: .constant(true))
}
