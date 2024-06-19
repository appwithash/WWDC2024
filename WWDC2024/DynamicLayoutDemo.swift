//
//  DynamicLayoutDemo.swift
//  WWDC2024
//
//  Created by ashutosh on 19/06/24.
//

import SwiftUI

struct DynamicLayoutDemo: View {
    @State var showList : Bool = false
    
    var dynamicLayout : AnyLayout{
        self.showList ? AnyLayout(VStackLayout(spacing: 0)) : AnyLayout(ZStackLayout(alignment: .top))
    }
    
    @State var showMore : Bool = false
    var body: some View {
        ZStack{
            ScrollView(.vertical,showsIndicators: false){
                dynamicLayout{
                    ForEach(1...10,id:\.self){ index in
                        
                        NotificationCell(index: index)
                            .frame(height: 80)
                            .background(Color.gray.opacity(0.1))
                            .background(Blur(style: .systemChromeMaterialDark))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .zIndex(3 - Double(index))
                            .onTapGesture {
                                withAnimation {
                                    self.showList.toggle()
                                }
                                self.showMore.toggle()
                            }
                            .visualEffect { content, proxy in
                                content
                                    .scaleEffect(self.showList || index == 1 ? 1 : index <= 3 ? 1 - 0.02*CGFloat(index) : 1)
                                    .offset(y : CGFloat(Double(index)*10))
                                    .opacity(index <= 3 ? 1 : self.showMore ? 1 : 0)
                            }
                    }
                }
               
                
            }
        }
    }
    
    
struct NotificationCell : View{
    var index : Int
    var body : some View{
        HStack{
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 30,height: 30)
                .cornerRadius(5)
                .padding(.leading)
            VStack{
                Text("Notifcation \(index)")
            }
            .foregroundStyle(.white)
            Spacer()
            
            
        }
      
    }
}
    
private func scaleFactor(for proxy: GeometryProxy) -> CGFloat {
        let y = proxy.frame(in: .global).origin.y
        let midY = -UIScreen.main.bounds.height / 2
        let scale = max(0.8, min(1, 1 - ((y - midY) / 500)))
        return scale
    }
}
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


struct ContentView2: View {
    var body: some View {
        ZStack(alignment: .top){
            // First view (bottom)
            Color.red
                .frame(width: 100, height: 100)
                .zIndex(1)
            // Second view
            Color.green
                .frame(width: 100, height: 100)
                .zIndex(2)
            // Third view (top)
            Color.blue
                .frame(width: 100, height: 100)
                .zIndex(3)
        }
    }
}


#Preview {
    DynamicLayoutDemo()
}
