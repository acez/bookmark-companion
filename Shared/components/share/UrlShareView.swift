//
//  UrlShareView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

public struct UrlShareView: UIViewControllerRepresentable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<UrlShareView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<UrlShareView>) {
    }
}

struct UrlShareView_Previews: PreviewProvider {
    static var previews: some View {
        UrlShareView(url: URL(string: "https://www.google.de")!)
    }
}
