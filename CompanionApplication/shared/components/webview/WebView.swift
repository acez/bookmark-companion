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

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://www.google.de")!)
    }
}
