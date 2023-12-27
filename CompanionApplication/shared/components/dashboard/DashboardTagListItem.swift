//
//  DashboardTagListItem.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct DashboardTagListItem: View {
    var tagName: String = ""
    var tagBookmarkCount: Int = 0
    var width: CGFloat = .infinity
    
    private let backgroundColor: Color = Color.green
    private let countBackgroundColor: Color = Color.gray.opacity(0.8)
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "tag")
                Text(self.tagName)
            }
            Spacer()
            ZStack {
                Text("\(self.tagBookmarkCount)")
                    .padding(5)
            }
                .background(self.countBackgroundColor)
                .cornerRadius(15)
        }
            .padding(6)
            .frame(width: self.width - (2*10))
            .background(self.backgroundColor)
            .cornerRadius(10)
    }
}

struct DashboardTagListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center) {
            DashboardTagListItem(tagName: "dummy-tag-1")
            DashboardTagListItem(tagName: "dummy-tag-2", tagBookmarkCount: 10)
            DashboardTagListItem(tagName: "dummy-tag-2", tagBookmarkCount: 10000000)
        }
    }
}
