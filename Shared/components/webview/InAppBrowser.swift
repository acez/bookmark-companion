//
//  InAppBrowser.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct InAppBrowser: View {
    var url: URL
    
    @State private var model: WebViewModel?
    
    var body: some View {
        VStack {
            if let obj = self.model {
                WebView(model: obj)
            }
            HStack {
                Button(action: {
                    self.model?.goBack()
                }) {
                    Image(systemName: "chevron.backward")
                        .padding(.horizontal, 20)
                }
                
                Button(action: {
                    self.model?.goForward()
                }) {
                    Image(systemName: "chevron.forward")
                        .padding(.horizontal, 20)
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
        }
        .onAppear() {
            self.model = WebViewModel(url: self.url)
        }
    }
}

struct InAppBrowser_Previews: PreviewProvider {
    static var previews: some View {
        InAppBrowser(url: URL(string: "https://www.google.de/")!)
    }
}
