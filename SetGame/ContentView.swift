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
            AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
                cardView(for: card)
            }
            dealCardsBtn
        }
    }
    
    var dealCardsBtn: some View {
        Button {
            game.dealCards()
        } label: {
            Text("Deal Cards").font(.system(size:30)).padding(.all)
        }
    }
    
    @ViewBuilder
    private func cardView(for card:SetGame.Card) -> some View {
        CardView(card: card).onTapGesture {
            game.select(card)
        }
    }
}

struct CardView: View {
    var card : SetGame.Card
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 10)
            shape.fill().foregroundColor(.white)
            if card.matched {
                shape.stroke(lineWidth: 4).foregroundColor(.blue)
            } else if card.selected {
                shape.stroke(lineWidth: 3).foregroundColor(.yellow)
            }  else {
                shape.stroke(lineWidth: 2).foregroundColor(.gray)
            }
            VStack {
                ForEach((0..<card.number), id: \.self) {_ in
                    cardView(card)
                }
            }.padding(2)
        }.aspectRatio(2/3, contentMode: .fit)
            .padding(4)
    }
    
    @ViewBuilder
    func cardView(_ card:SetGame.Card) -> some View {
        switch card.shape
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
