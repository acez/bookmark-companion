//
// ShareViewController.swift
// Created by Christian Wilhelm
//

import UIKit
import SwiftUI
import Linkding

class ShareViewController: UIViewController {
    private var sharedUrl: String = ""
    
    private func getSharedUrl() async -> String {
        for item in extensionContext!.inputItems as! [NSExtensionItem] {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                        let item = try? await itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil)
                        return (item as! NSURL).absoluteURL!.absoluteString
                    }
                }
            }
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let sharedUrl = await self.getSharedUrl()
            let container = ShareBookmarkContainerView(onClose: {
                self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            }, url: sharedUrl)
            let child = UIHostingController(rootView: container)

            self.view.addSubview(child.view)

            child.view.translatesAutoresizingMaskIntoConstraints = false
            child.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            child.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            child.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
    }
}
