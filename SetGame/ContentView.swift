//
//  ContentView.swift
//  SetGame
//
//  Created by Hang Zhang on 9/27/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game = GameController()
    
    var body: some View {
        VStack {
            AspectVGrid(items: game.dealtCards, aspectRatio: 2/3) { card in
                cardView(for: card)
            }
            HStack {
                if game.undealtCards.count > 0 {
                    Spacer()
                    cardDeckView
                }
                Spacer()
                if game.discardPile.count > 0 {
                    discardPileView
                    Spacer()
                }
            }
        }
    }
    
    var cardDeckView: some View {
        ZStack {
            ForEach(game.undealtCards) { card in
                CardView(card: card, faceUp: false)
            }
        }
        .onTapGesture {
            game.dealCards()
        }
        .frame(width: Constants.DeckWidth, height: Constants.DeckWidth / Constants.AspectRatio, alignment: .bottom)
    }
    
    var discardPileView: some View {
        ZStack {
            ForEach(game.discardPile) { card in
                CardView(card: card, faceUp: true)
            }
        }
        .frame(width: Constants.DeckWidth, height: Constants.DeckWidth / Constants.AspectRatio, alignment: .bottom)
    }

    
    @ViewBuilder
    private func cardView(for card:SetGame.Card) -> some View {
        CardView(card: card, faceUp: true).onTapGesture {
            game.select(card)
        }
    }
    
    private struct Constants {
        static let DeckWidth : CGFloat = 90
        static let AspectRatio : CGFloat = 2/3
    }
}

struct CardView: View {
    var card : SetGame.Card
    var faceUp : Bool
    
    init(card : SetGame.Card, faceUp : Bool ) {
        self.card = card
        self.faceUp = faceUp
    }
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 10)
            if faceUp {
                shape.fill().foregroundColor(.white)
                if card.matched {
                    shape.stroke(lineWidth: 4).foregroundColor(.blue)
                } else if card.selected {
                    shape.stroke(lineWidth: 3).foregroundColor(.yellow)
                }  else {
                    shape.stroke(lineWidth: 2).foregroundColor(.gray)
                }
                VStack {
                    ForEach((0..<card.count), id: \.self) {_ in
                        shapesView(from: card.shape)
                    }
                }.padding(2)
            } else {
                shape.fill().foregroundColor(.red)
            }
        }.aspectRatio(2/3, contentMode: .fit)
            .padding(4)
    }
    
    @ViewBuilder
    func shapesView(from shape:SetGame.ShapeType) -> some View {
        switch shape
        {
        case .oval:
            OvalView(shading: card.shade, color: CardView.color(card.color))
        case .squiggle:
            SquiggleView(shading: card.shade, color: CardView.color(card.color))
        case .diamond:
            DiamondView(shading: card.shade, color: CardView.color(card.color))
        }
    }
    
    static func color(_ color:SetGame.ColorType) -> Color {
        switch color {
        case .red :     return Color.red
        case .green :   return Color.green
        case .purple :  return Color.purple
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
