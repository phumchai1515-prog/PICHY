//
//  ShareSheet.swift
//  PICHY
//
//  Thin SwiftUI wrapper over UIActivityViewController for sharing files (e.g.
//  the exported schedule PDF).
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// Identifiable URL box so it can drive a `.sheet(item:)`.
struct ShareableFile: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
