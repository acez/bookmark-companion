//
// UrlLinkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct UrlLinkView: View {
    private var url: String?

    public init(url: String?) {
        self.url = url
    }

    public var body: some View {
        let url = self.getUrl()
        VStack {
            if (url != nil) {
                Link(destination: url!, label: {
                    Image(systemName: "link")
                })
            } else {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
        }
        .padding(.leading, 28)
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

struct UrlLinkView_Previews: PreviewProvider {
    static let url = "https://www.github.com"
    static let emptyUrl: String? = nil
    
    static var previews: some View {
        UrlLinkView(url: url)
        UrlLinkView(url: emptyUrl)
    }
}
