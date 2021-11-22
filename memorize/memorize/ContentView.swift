//
//  ContentView.swift
//  memorize
//
//  Created by Hang Zhang on 9/18/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var gameController : GameViewModel
    
    init(game: GameViewModel) {
        gameController = game
    }
    
    var body: some View {
        VStack {
            TitleView
            Text("\(gameController.name)")
                .font(.title)
                .foregroundColor(gameController.cardColor)
            Divider()
            ScrollView {
                LazyVGrid(columns:[GridItem(.adaptive(minimum: 80))]) {
                    ForEach(gameController.cards) { card in
                        CardView(card: card,
                                 cardColor: gameController.cardColor)
                            .onTapGesture {
                                gameController.select(card)
                            }
                    }
                }.foregroundColor(gameController.cardColor)
            }
            Spacer()
            Text("\(gameController.score)").font(.title).foregroundColor(.green)
            newGameBtn
        }.padding(.horizontal)
    }
    
    var TitleView: some View {
        Text("Memorize!")
            .font(.system(size: 56))
    }
    var newGameBtn: some View {
        Button {
            gameController.startNewGame()
        } label: {
            Text("New Game").font(.system(size:30)).padding(.all)
        }
    }
}

struct CardView : View {
    let card : GameModel.Card
    let cardColor : Color
    
    var body: some View {
        GeometryReader  { geometry in
            ZStack{
                let shape = RoundedRectangle(cornerRadius: ViewConstants.CornerRadius)
                if card.faceUp {
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(Color.red, lineWidth: ViewConstants.BorderWidth, antialiased: true)
                    Text(card.content).font(.system(size:font(geometry)))
                } else if card.matched {
                    shape.opacity(0)
                } else {
                    shape.foregroundColor(cardColor)
                }
            }
        }.aspectRatio(ViewConstants.AspectRatio,contentMode: .fit)
    }
    
    private func font(_ geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.height, geometry.size.height) * ViewConstants.FontScaleFactor
    }
    
    private struct ViewConstants {
        static let BorderWidth : CGFloat = 3
        static let CornerRadius : CGFloat = 20
        static let FontScaleFactor : CGFloat = 0.5
        static let AspectRatio : CGFloat = 2/3
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = GameViewModel()
        ContentView(game:game).preferredColorScheme(.light)
    }
}
