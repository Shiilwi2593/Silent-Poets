//
//  SheetAlert.swift
//  SilentPoets
//
//  Created by Trịnh Kiết Tường on 17/10/24.
//

import SwiftUI

struct SheetAlert: View {
    var image: String
    var imageForeground: Color
    var title: String
    
    
    var body: some View {
        VStack{
            Image(systemName: "\(image)")
                .resizable()
                .foregroundStyle(imageForeground)
                .frame(width: 100, height: 100)
            Text("\(title)")
                .font(.headline)
                .padding(.top, 12)
        }
        
    }
}

#Preview {
    SheetAlert(image: "tray.and.arrow.down.fill", imageForeground: .green, title: "Added to Favorite List")
}
