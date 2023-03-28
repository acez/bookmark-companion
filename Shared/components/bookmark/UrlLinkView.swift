//
// UrlLinkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct UrlLinkView: View {
    @AppStorage(SharedSettingKeys.useInAppBrowser.rawValue, store: AppStorageSupport.shared.sharedStore) var useInAppBrowser: Bool = false
    
    private var url: String?
    
    @State private var inAppBrowserOpen: Bool = false

    public init(url: String?) {
        self.url = url
    }

    public var body: some View {
        let url = self.getUrl()
        VStack {
            if (url != nil) {
                if self.useInAppBrowser {
                    Button(action: {
                        self.inAppBrowserOpen = true
                    }) {
                        Image(systemName: "link")
                    }
                } else {
                    Link(destination: url!, label: {
                        Image(systemName: "link")
                    })
                }
            } else {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
            }
        }
        .padding(.leading, 28)
        .sheet(isPresented: self.$inAppBrowserOpen, content: {
            if let urlObj = URL(string: self.url!) {
                InAppBrowser(url: urlObj)
            } else {
                Text("Error: Invalid URL").foregroundColor(.red)
            }
        })
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
