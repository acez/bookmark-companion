//
//  WebView.swift
//  Created by Christian Wilhelm
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<WebView>) -> SFSafariViewController {
        return SFSafariViewController(url: self.url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<WebView>) {
    }
}

#Preview("WebView") {
    WebView(url: URL(string: "https://www.google.de")!)
}
