//
//  SearchView.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 14/10/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var isTabBarShowing: Bool

    var body: some View {
        Text("Search")
    }
}

#Preview {
    SearchView(isTabBarShowing: .constant(true))
}
