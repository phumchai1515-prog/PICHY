//
//  ImageProcessing.swift
//  PICHY
//
//  Downscales picked profile photos so we don't persist multi-megabyte images.
//

import UIKit

enum ImageProcessing {
    private static let maxDimension: CGFloat = 512
    private static let jpegQuality: CGFloat = 0.8

    /// Returns downscaled JPEG data, or nil if the input isn't a valid image.
    static func downscaledJPEG(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resize(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: jpegQuality)
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
