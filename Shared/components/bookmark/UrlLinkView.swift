//
// UrlLinkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct UrlLinkView: View {
    var url: String?

    public init(url: String?) {
        self.url = url
    }

    public var body: some View {
        let url = self.getUrl()
        if (url != nil) {
            Link(destination: url!, label: {
                Image(systemName: "link")
            })
        } else {
            Image(systemName: "xmark")
                .foregroundColor(.red)
        }
    }

    private func getUrl() -> URL? {
        guard let url = self.url else {
            return nil
        }
        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return nil
        }
        return URL(string: urlString)
    }
}
