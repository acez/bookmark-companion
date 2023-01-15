//
//  BookmarkSorter.swift
//  Created by Christian Wilhelm
//

import Foundation

class BookmarkSorter {
    private let sortField: SortField
    private let sortOrder: SortOrder
    
    init(sortField: SortField, sortOrder: SortOrder) {
        self.sortField = sortField
        self.sortOrder = sortOrder
    }
    
    func compareBookmark(a: LinkdingBookmarkEntity, b: LinkdingBookmarkEntity) -> Bool {
        let compareOrder = self.sortOrder == .ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
        
        switch self.sortField {
        case .url:
            return a.url.compare(b.url, options: .caseInsensitive) == compareOrder
        case .title:
            return a.displayTitle.compare(b.displayTitle, options: .caseInsensitive) == compareOrder
        case .description:
            return a.displayDescription.compare(b.displayDescription, options: .caseInsensitive) == compareOrder
        case .dateAdded:
            guard let dateA = a.dateAdded else {
                return true
            }
            guard let dateB = b.dateAdded else {
                return true
            }
            return dateA.compare(dateB) == compareOrder
        case .dateModified:
            guard let dateA = a.dateModified else {
                return true
            }
            guard let dateB = b.dateModified else {
                return true
            }
            return dateA.compare(dateB) == compareOrder
        }
    }
}
