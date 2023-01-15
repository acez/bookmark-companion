//
//  SortField.swift
//  Created by Christian Wilhelm
//

import Foundation

enum SortField: String {
    case url, title, description, dateAdded
    var id: Self { self }
}
