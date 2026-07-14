//
//  DashboardTagListItem.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct DashboardTagListItem: View {
    var tagName: String = ""
    var tagBookmarkCount: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(self.tagName)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text("\(self.tagBookmarkCount)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color(.tertiarySystemFill), in: Capsule())

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }
}

struct DashboardTagListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            DashboardTagListItem(tagName: "dummy-tag-1")
            DashboardTagListItem(tagName: "dummy-tag-2", tagBookmarkCount: 10)
            DashboardTagListItem(tagName: "dummy-tag-3", tagBookmarkCount: 10000000)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
