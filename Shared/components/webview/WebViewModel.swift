//
//  WebViewModel.swift
//  Created by Christian Wilhelm
//

import Foundation
import WebKit

class WebViewModel: ObservableObject {
    private let webView: WKWebView
    
    init(url: URL) {
        self.webView = WKWebView()
        self.webView.load(URLRequest(url: url))
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    func getWebView() -> WKWebView {
        return self.webView
    }
    
    func goBack() {
        self.webView.goBack()
    }
    
    func goForward() {
        self.webView.goForward()
    }
}
