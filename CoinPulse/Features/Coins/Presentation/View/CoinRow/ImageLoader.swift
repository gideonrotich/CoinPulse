//
//  ImageLoader.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import SwiftUI

struct CircularImageView: View {
    var url: String? = ""
    var size: CGSize = CGSize(width: 50, height: 50)
    var placeholderImage: Image = Image("")
        .resizable()
    
    var body: some View {
        Group {
            ImageViewer(
                url: cleanUpUrl(from: url ?? ""),
                size: size,
                cornerRadius: 50,
                placeholderImage: placeholderImage
            )
        }
    }
}

struct ImageViewer<Content: View, Placeholder: View>: View {
    
    private let url: String?
    private let contentMode: ContentMode
    private let size: CGSize
    private let cornerRadius: CGFloat
    private let placeholderImage: Image
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    
    @State private var isLoading: Bool = true
    @State private var loadedImage: UIImage? = nil
    @State private var loadError: Bool = false
    
    
    init(
        url: String?,
        contentMode: ContentMode = .fill,
        size: CGSize,
        cornerRadius: CGFloat = 0,
        placeholderImage: Image = Image(systemName: "photo"),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.size = size
        self.cornerRadius = cornerRadius
        self.placeholderImage = placeholderImage
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            if loadError || loadedImage == nil {
                
                placeholder()
                    .frame(width: size.width, height: size.height).cornerRadius(cornerRadius)
            } else if let image = loadedImage {
                
                content(Image(uiImage: image))
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(cornerRadius)
            }
        }
        .frame(width: size.width, height: size.height)
        .onAppear {
            loadImage()
        }
        .onChange(of: url) {
            resetAndLoadImage()
        }
    }
    
    
    private func resetAndLoadImage() {
        isLoading = true
        loadError = false
        loadedImage = nil
        loadImage()
    }
    
    private func loadImage() {
        guard let urlString = url, let url = URL(string: urlString) else {
            isLoading = false
            loadError = true
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    loadError = true
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    loadError = true
                    return
                }
                
                loadedImage = image
            }
        }.resume()
    }
}


extension ImageViewer where Content == AnyView, Placeholder == AnyView {
    init(
        url: String?,
        contentMode: ContentMode = .fill,
        size: CGSize,
        cornerRadius: CGFloat = 0,
        placeholderImage: Image = Image(systemName: "photo")
    ) {
        self.init(
            url: url,
            contentMode: contentMode,
            size: size,
            cornerRadius: cornerRadius,
            placeholderImage: placeholderImage,
            content: { image in AnyView(image.resizable().aspectRatio(contentMode: contentMode)) },
            placeholder: { AnyView(placeholderImage.resizable().aspectRatio(contentMode: contentMode)) }
        )
    }
}



func cleanUpUrl(from urlString: String) -> String {
    if urlString.hasSuffix(".svg") {
        return urlString.replacingOccurrences(of: ".svg", with: ".png")
    }
    return urlString
}


