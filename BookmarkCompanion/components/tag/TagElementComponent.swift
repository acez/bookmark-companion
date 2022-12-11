//
// TagElementComponent.swift
// Created by Christian Wilhelm
//
import SwiftUI

struct TagElementComponent: View {
    var name: String = ""

    var body: some View {
        HStack {
            Text("#\(name)")
                .lineLimit(1)
        }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.orange)
            .cornerRadius(15)
    }
}
