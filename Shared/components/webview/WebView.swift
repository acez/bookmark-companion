//
//  WebView.swift
//  Created by Christian Wilhelm
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let model: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        return model.getWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(model: WebViewModel(url: URL(string: "https://www.google.de")!))
    }
}
