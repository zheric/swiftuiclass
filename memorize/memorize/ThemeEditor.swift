//
//  ThemeEditor.swift
//  memorize
//
//  Created by Eric Zhang on 11/22/21.
//

import SwiftUI

struct ThemeEditor: View {
    @Binding var theme : Theme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            NavigationView {
                Form{
                    nameSection
                    addEmojisSection
                    removeEmojiSection
                    itemCountSection
                    colorPickerSection
                }
            }
            closeBtn
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text:$theme.name)
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            theme.emojis = (theme.emojis + emojis)
                .filter { $0.isEmoji }
                .removingDuplicateCharacters
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = theme.emojis.removingDuplicateCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                theme.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
    
    var itemCountSection : some View {
        Section(header: Text("Number of Pairs to Play")) {
            TextField("\($theme.numPairsOfEmojis)",
                      value: $theme.numPairsOfEmojis, formatter: NumberFormatter())
                .keyboardType(.numberPad)
        }
    }
    
    var colorPickerSection: some View {
            Section(header: Text("Color")) {
                Picker("Pick a color", selection: $theme.color) {
                    ForEach(["red", "green", "blue"], id:\.self) {
                        Text("\($0)")
                    }
                }
            }
    }
    
    var closeBtn : some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Close")
        }
    }
}

struct ThemeEditor_Previews: PreviewProvider {
    static var previews: some View {
        ThemeEditor(theme: .constant(ThemeStore().theme(at: 0)))
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension String {
    var removingDuplicateCharacters: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}
