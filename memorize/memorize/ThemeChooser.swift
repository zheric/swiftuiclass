//
//  ThemeChooser.swift
//  memorize
//
//  Created by Eric Zhang on 11/22/21.
//

import SwiftUI

struct ThemeChooser: View {
    @EnvironmentObject var store: ThemeStore
    // we inject a Binding to this in the environment for the List and EditButton
    // using the \.editMode in EnvironmentValues
    @State private var editMode: EditMode = .inactive
    @State private var themeToEdit: Theme?
    @State var isAddingNewTheme = false
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            List{
                ForEach(store.themes) { theme in
                    NavigationLink(destination: destinationView(theme)) {
                        ThemeSummaryView(theme: theme)
                            .gesture(editMode == .active ? pop(theme) : nil)
                    }
                }
                .onDelete { IndexSet in
                    store.themes.remove(atOffsets: IndexSet)
                }
                .onMove { IndexSet, newOffSet in
                    store.themes.move(fromOffsets: IndexSet, toOffset: newOffSet)
                }
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) { addNewTheme() }
            }
            .environment(\.editMode, $editMode)
        }
        .popover(item: $themeToEdit) { theme in
            ThemeEditor(theme: $store.themes[theme])
        }
    }
    
    @ViewBuilder
    func destinationView(_ theme:Theme) -> some View {
        GameView(with: theme)
    }
    
    func pop(_ theme : Theme) -> some Gesture {
        TapGesture().onEnded {
            themeToEdit = theme
        }
    }
    
    func addNewTheme() -> some View {
        editMode == .active ?
            Button {
                themeToEdit = store.addTheme(name: "", emojis: "", color: "red")
            } label: {
                Text("Add")
            }
            .popover(item: $themeToEdit) { theme in
                ThemeEditor(theme: $store.themes[theme])
            }
            : nil
    }
}

struct ThemeSummaryView: View {
    var theme: Theme
    @ScaledMetric static var emojiSize : CGFloat = 10
    var body: some View {
        VStack (alignment: .leading){
            Text(theme.name)
            Text(theme.emojis).font(.system(size:ThemeSummaryView.emojiSize))
        }
    }
}

struct ThemeChooser_Previews: PreviewProvider {
    static var previews: some View {
        ThemeChooser().environmentObject(ThemeStore())
    }
}
