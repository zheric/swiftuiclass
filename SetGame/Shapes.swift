//
//  Shapes.swift
//  SetGame
//
//  Created by Hang Zhang on 9/28/21.
//

import SwiftUI

struct OvalShape: Shape {
    var length: CGFloat
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let halfLength = length / 2
        let start = CGPoint(x: center.x, y: center.y - radius)
        
        var p = Path()
        
        p.move(to: start)
        p.addLine(to: CGPoint(x:start.x-halfLength, y:start.y))
        
        let leftArcCenter = CGPoint(
            x: center.x - halfLength,
            y: center.y
        )
        //p.move(to: leftArcCenter)
        p.addArc(center: leftArcCenter,
                 radius: radius,
                 startAngle: Angle(degrees: 270),
                 endAngle: Angle(degrees: 90),
                 clockwise: true)
        
        p.addLine(to: CGPoint(x: center.x+halfLength, y: center.y+radius))
        
        let rightArcCenter = CGPoint(
            x: center.x + halfLength,
            y: center.y
        )
        
        p.addArc(center: rightArcCenter,
                 radius: radius,
                 startAngle: Angle(degrees: 90),
                 endAngle: Angle(degrees: 270),
                 clockwise: true)
        p.addLine(to: start)
        
        return p
    }
}

struct DiamondShape: Shape {
    var width : CGFloat
    var aspectRatio: CGFloat // height vs width
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let halfWidth = width / 2
        var p = Path()
        p.move(to: CGPoint(x: center.x,
                           y: center.y-(width*aspectRatio)/2))
        p.addLine(to: CGPoint(x:center.x-halfWidth,
                              y:center.y))
        p.addLine(to: CGPoint(x:center.x,
                              y:center.y+(width*aspectRatio)/2))
        p.addLine(to: CGPoint(x:center.x+halfWidth,
                              y:center.y))
        p.addLine(to: CGPoint(x: center.x,
                              y: center.y-(width*aspectRatio)/2))
        return p
    }
    
}

struct SquiggleShape: Shape {
    var width : CGFloat
    var height : CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        let start = CGPoint(x: center.x+width/2, y: center.y - height/2)
        p.move(to: start)
        
        let to = CGPoint(x:start.x-width, y:start.y)
        let c1 = CGPoint(x:center.x+width*0.1, y:start.y+height*0.5)
        let c2 = CGPoint(x:center.x-width*0.1, y:start.y-height*0.5)
        
        p.addCurve(to: to, control1: c1, control2: c2)
        
        
        let to1 = CGPoint(x:to.x, y:to.y+height)
        let c3 = CGPoint(x: to.x-width*0.3, y: center.y)
        p.addQuadCurve(to: to1, control: c3)
        
        let to2 = CGPoint(x:start.x, y:start.y + height)
        let c4 = CGPoint(x:center.x-width*0.1, y:to2.y-height*0.5)
        let c5 = CGPoint(x:center.x+width*0.1, y:to2.y+height*0.5)
        
        p.addCurve(to: to2, control1: c4, control2: c5)
        
        
        let c6 = CGPoint(x: start.x+width*0.3, y: center.y)
        p.addQuadCurve(to: start, control: c6)
        
        
        return p
    }
}

struct DiamondView: View {
    var shading : SetGame.ShadingType
    var color : Color
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width * 0.8
            ZStack{
                let diamond = DiamondShape(width: w, aspectRatio: 0.3)
                
                switch shading {
                case .striped:
                    let stripe = Stripes(numStripes: 35).stroke(lineWidth: 1).foregroundColor(color)
                    stripe.mask(diamond).overlay(diamond.stroke(lineWidth: 3).foregroundColor(color))
                case .solid:
                    diamond.fill(color)
                default:
                    diamond.stroke(lineWidth: 3).foregroundColor(color)
                }
            }
        }
    }
}

struct SquiggleView : View {
    var shading : SetGame.ShadingType
    var color : Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                let w = geometry.size.width * 0.6
                let h = w * 0.5
                
                let squiggle = SquiggleShape(width: w, height: h)
                
                switch shading {
                case .striped:
                    let stripe = Stripes(numStripes: 35).stroke(lineWidth: 1).foregroundColor(color)
                    stripe.mask(squiggle).overlay(squiggle.stroke(lineWidth: 3).foregroundColor(color))
                case .solid:
                    squiggle.fill(color)
                default:
                    squiggle.stroke(lineWidth: 3).foregroundColor(color)
                }
            }
        }
    }
}

struct OvalView: View {
    var shading : SetGame.ShadingType
    var color : Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                let l = geometry.size.width * 0.6
                let r = geometry.size.width * 0.15
                let oval = OvalShape(length: l, radius: r)
                
                switch shading {
                case .striped:
                    let stripe = Stripes(numStripes: 35).stroke(lineWidth: 1).foregroundColor(color)
                    stripe.mask(oval).overlay(oval.stroke(lineWidth: 3).foregroundColor(color))
                case .solid:
                    oval.fill(color)
                default:
                    oval.stroke(lineWidth: 3).foregroundColor(color)
                }
            }
        }
    }
}

struct Stripes : Shape {
    var numStripes : Int
    
    func path(in rect: CGRect) -> Path {
        let start = CGPoint(x: rect.origin.x, y: rect.origin.y)
        
        let width = rect.width / CGFloat(numStripes)
        
        var p = Path()
        
        for i in 0..<numStripes {
            let top = CGPoint(x:start.x + CGFloat(i)*width, y: start.y)
            let bottom = CGPoint(x:start.x+CGFloat(i)*width, y: rect.height)
            p.move(to: top)
            p.addLine(to: bottom)
        }
        
        return p
    }
    
    
}


struct Shapes_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DiamondView(shading: .solid, color:.blue)
            
            OvalView(shading: .striped, color: .red)
            SquiggleView(shading: .striped, color: .yellow)
        }
    }
}
