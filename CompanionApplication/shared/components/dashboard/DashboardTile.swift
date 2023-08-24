//
//  DashboardTile.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct DashboardTile: View {
    var title: String = ""
    var count: Int = 0
    var width: CGFloat = CGFloat.infinity
    var color: Color = Color.red
    var iconName: String = "tray"
    
    private let outerPadding: CGFloat = 5.0
    private let innerPadding: CGFloat = 10.0
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: self.iconName)
                        .bold()
                    Spacer()
                    Text("\(self.count)")
                        .font(.headline)
                        
                }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                HStack {
                    Text(self.title)
                }
            }
            .padding(self.innerPadding)
        }
            .frame(width: self.calculateWidth())
            .background(self.color)
            .cornerRadius(10)
            .padding(self.outerPadding)
    }
    
    private func calculateWidth() -> CGFloat {
        return self.width - self.innerPadding - self.outerPadding
    }
}

struct DashboardTile_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            HStack {
                DashboardTile(title: "All Bookmarks", count: 100, width: geometry.size.width / 2.0, color: Color.red)
                DashboardTile(title: "Unread Bookmarks", count: 42, width: geometry.size.width / 2.0, color: Color.blue, iconName: "tray.full.fill")
            }
        }
    }
}
