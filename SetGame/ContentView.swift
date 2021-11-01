//
//  ContentView.swift
//  SetGame
//
//  Created by Hang Zhang on 9/27/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game = GameController()
    @Namespace var dealingCards
    
    var body: some View {
        VStack {
            restartButton
            AspectVGrid(items: game.dealtCards, aspectRatio: 2/3) { card in
                dealtCardView(for: card)
                    .matchedGeometryEffect(id: card.id, in: dealingCards)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
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
    
    var restartButton: some View {
        Button("restart") {
            game.restart()
        }
    }
    
    var cardDeckView: some View {
        ZStack {
            ForEach(game.undealtCards) { card in
                CardView(card: card, faceUp: false)
                    .matchedGeometryEffect(id: card.id, in: dealingCards)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
            }
        }
        .onTapGesture {
            withAnimation {
                game.dealCards()
            }
        }
        .frame(width: Constants.DeckWidth, height: Constants.DeckWidth / Constants.AspectRatio, alignment: .bottom)
    }
    
    var discardPileView: some View {
        ZStack {
            ForEach(game.discardPile) { card in
                CardView(card: card, faceUp: true)
                    .matchedGeometryEffect(id: card.id, in: dealingCards)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity))
            }
        }
        .frame(width: Constants.DeckWidth, height: Constants.DeckWidth / Constants.AspectRatio, alignment: .bottom)
    }

    
    @ViewBuilder
    private func dealtCardView(for card:SetGame.Card) -> some View {
        cardify(theCard: card, isFaceUp: true)
            .onTapGesture {
                withAnimation {
                    game.select(card)
                }
            }
    }
    
    private struct Constants {
        static let DeckWidth : CGFloat = 90
        static let AspectRatio : CGFloat = 2/3
    }
}

struct Cardify : AnimatableModifier {
    var rotation : Double
    var card : SetGame.Card
    var faceUp : Bool
    
    var shouldRotate : Bool {
        card.matched && !card.discarded
    }
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(card : SetGame.Card, faceUp:Bool ) {
        rotation = (card.matched && !card.discarded) ? 360 : 0
        self.card = card
        self.faceUp = faceUp
    }
    		
    func body(content: Content) -> some View {
        CardView(card: card, faceUp: self.faceUp)
            .rotation3DEffect(Angle.degrees(rotation), axis: (x: 0, y: 1, z: 0))
    }
}

extension View {
    func cardify(theCard: SetGame.Card, isFaceUp: Bool) -> some View {
        self.modifier(Cardify(card:theCard, faceUp:isFaceUp))
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
        }
        .aspectRatio(2/3, contentMode: .fit)
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
