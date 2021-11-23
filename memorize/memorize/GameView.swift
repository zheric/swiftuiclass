//
//  ContentView.swift
//  memorize
//
//  Created by Hang Zhang on 9/18/21.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var gameController : GameViewModel
    
    init(with theme:Theme) {
        gameController = GameViewModel(with: theme)
    }
    
    var body: some View {
        VStack {
            HStack {
                titleView
                Spacer()
                scoreView
            }
            gameView
            Spacer()
            restartBtn
        }.padding(.horizontal)
    }
    
    var titleView: some View {
        Text("\(gameController.name)")
            .font(.title)
            .foregroundColor(gameController.cardColor)
    }
    
    var scoreView: some View {
        Text("\(gameController.score)")
                .font(.title)
                .foregroundColor(gameController.cardColor)
    }
    
    var gameView: some View {
        AspectVGrid(items: gameController.cards, aspectRatio: 2/3) { card in
            CardView(card: card, cardColor: gameController.cardColor)
                .onTapGesture {
                    withAnimation {
                        gameController.select(card)
                    }
                }.padding(2)
        }.foregroundColor(gameController.cardColor)
    }
    
    var restartBtn: some View {
        Button {
            gameController.startNewGame()
        } label: {
            Text("Restart").font(.system(size:30)).padding(.all)
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
    static let theme = Theme(name: "Vehicles", emojis: "🚗🚌🚎🏎🚑🚜🛻🚒🚅✈️", color: "red", numPairsOfEmojis: 10)
    static var previews: some View {
        GameView(with: theme).preferredColorScheme(.light)
    }
}
