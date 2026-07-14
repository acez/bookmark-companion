//
//  DashboardTile.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct DashboardTile: View {
    var title: String = ""
    var count: Int = 0
    var color: Color = .blue
    var iconName: String = "bookmark.fill"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: self.iconName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(self.color.gradient, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                Spacer()
            }

            Text("\(self.count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Text(self.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct DashboardTile_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 14) {
            DashboardTile(title: "All bookmarks", count: 100, color: .blue, iconName: "bookmark.fill")
            DashboardTile(title: "Unread bookmarks", count: 42, color: .orange, iconName: "tray.full.fill")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
