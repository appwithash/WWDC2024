//
//  CustomTextAnimationView.swift
//  WWDC2024
//
//  Created by ashutosh on 19/06/24.
//

import SwiftUI

struct CustomTextAnimationView: View {
    @State var isVisible = true
    
    var body: some View {
        VStack {
            Spacer()
            let attText = Text("Text Renderer")
                .font(.system(size: 40))
                .customAttribute(CustomTextAttribute())
                .foregroundStyle(.blue)
                .bold()
            if self.isVisible{
                Text("This is SwiftUI \(attText)")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .transition(TextTransition())
            }
            Spacer()
            Button(isVisible ? "Hide Text" : "Show Text") {
                    isVisible.toggle()
               
            }
            .foregroundStyle(.white)
            .padding(.all,10)
            .background(Color.blue)
            .cornerRadius(15)
            .controlSize(.extraLarge)
            
        }
        .padding(40)
    }
}

struct CustomTextRenderer : TextRenderer, Animatable{
    var elapsedTime : TimeInterval
    var elementDuration : TimeInterval
    var totalDuration : TimeInterval
    
    var animatableData: Double{
        get { elapsedTime }
        set { elapsedTime = newValue }
    }
    
    var spring: Spring {
         .snappy(duration: elementDuration, extraBounce: 0.4)
     }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for run in layout.flattenedRuns{
            if run[CustomTextAttribute.self] != nil {
                let delay = elementDelay(count: layout.flattenedRunSlices.count)
                for (index,slice) in layout.flattenedRunSlices.enumerated(){
                    let timeOffset = TimeInterval(index) * delay
                    let elementTime = max(0, min(elapsedTime - timeOffset, elementDuration))
                    var copy = ctx
                    draw(slice, at: elementTime, in: &copy)
                }
            }else{
                var copy = ctx
                copy.opacity = UnitCurve.easeIn.value(at: elapsedTime/0.2)
                copy.draw(run)
            }
        }
    }
    
    func draw(_ slice: Text.Layout.RunSlice, at time: TimeInterval, in context: inout GraphicsContext) {
        let progress = time/elementDuration
        
        let opacity = UnitCurve.easeIn.value(at: 1.4*progress)
        
        let blurRadius = slice.typographicBounds.rect.height/16 * UnitCurve.easeIn.value(at: 1 - progress)
        
        let translationY = spring.value(
                  fromValue: -slice.typographicBounds.descent,
                  toValue: 0,
                  initialVelocity: 0,
                  time: time)
        
        context.translateBy(x: 0, y: translationY)
        context.addFilter(.blur(radius: blurRadius))
        context.opacity = opacity
        context.draw(slice, options: .disablesSubpixelQuantization)
    }
    
    func elementDelay(count: Int) -> TimeInterval {
       let count = TimeInterval(count)
       let remainingTime = totalDuration - count * elementDuration

       return max(remainingTime / (count + 1), (totalDuration - elementDuration) / count)
    }
    
    
}


struct TextTransition : Transition{
   
    func body(content: Content, phase: TransitionPhase) -> some View {
        let duration = 0.9
        
        let elapsedTime = phase.isIdentity ? duration : 0
        
        let renderer = CustomTextRenderer(elapsedTime: elapsedTime, elementDuration: 0.4, totalDuration: duration)
        
        content.transaction { t in
            if !t.disablesAnimations{
                t.animation = .linear(duration: duration)
            }
        } body: { view in
            view.textRenderer(renderer)
        }

    }
    
}
   
extension Text.Layout {
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        self.flatMap { line in
            line
        }
    }

    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }
}

struct CustomTextAttribute : TextAttribute {}
#Preview {
    CustomTextAnimationView()
}
