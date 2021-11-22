//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScaleForBackground)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry, false))
                )
                .gesture( TapGesture(count: 2)
                            .onEnded({ _ in
                                withAnimation {
                                    zoomToFit(document.backgroundImage, in: geometry.size)
                                }
                            })
                            .exclusively(before:
                                            TapGesture(count: 1)
                                            .onEnded({ _ in
                                                withAnimation {
                                                    document.clearSelectedEmojis()
                                                }
                                            }))
                )
                
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                       let view = emojiView(emoji: emoji)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScaleForEmoji(emoji))
                            .position(position(for: emoji, in: geometry))
                            .onTapGesture {
                                document.selectEmoji(emoji)
                            }.gesture(
                                emojiPanGesture(for: emoji)//.simultaneously(with: zoomGesture())
                            ).onLongPressGesture {
                                document.removeEmoji(emoji)
                            }
                        view
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    // MARK: - Drag and Drop
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry, emoji.selected)
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy,_ selected: Bool) -> CGPoint {
        let center = geometry.frame(in: .local).center
        let offset = selected ? emojiDragOffset : CGSize.zero
        let zoomscale = selected ? zoomScale : steadyStateZoomScale
        return CGPoint(
            x: center.x + (CGFloat(location.x) + offset.width) * zoomscale + panOffset.width,
            y: center.y + (CGFloat(location.y) + offset.height) * zoomscale + panOffset.height
        )
    }
    
    // MARK: - Zooming
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var zoomScaleForBackground: CGFloat {
        document.selectedEmojis().count > 0 ? steadyStateZoomScale : zoomScale
    }
    
    private func zoomScaleForEmoji(_ emoji: EmojiArtModel.Emoji) -> CGFloat {
        if document.selectedEmojis().count > 0 && !emoji.selected {
            return steadyStateZoomScale
        }
        return steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                    gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                let selected = document.selectedEmojis()
                if selected.count == 0 {
                    steadyStateZoomScale *= gestureScaleAtEnd
                } else {
                    for emoji in selected {
                        document.scaleEmoji(emoji, by: steadyStateZoomScale * gestureScaleAtEnd)
                    }
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    @GestureState private var emojiDragOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private func emojiPanGesture(for emoji:EmojiArtModel.Emoji) -> some Gesture {
        DragGesture()
            .updating($emojiDragOffset) { value, emojiDragOffset, _ in
                emojiDragOffset = emoji.selected ? value.translation : CGSize.zero
            }
            .onEnded { value in
                if emoji.selected {
                    document.moveSelectecEmojis(by: value.translation)
                }
            }
    }
    
    // MARK: - Emoji View
    struct emojiView: View {
        var emoji: EmojiArtModel.Emoji

        var body: some View {
            let size: CGFloat? = CGFloat(emoji.size+2)
            ZStack {
                if emoji.selected {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(lineWidth:1)
                        .foregroundColor(.blue)
                        .frame(width: size, height: size, alignment: .center)
                }
                Text(emoji.text)
            }
        }
    }
    
    
    // MARK: - Palette
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
