//
//  Home.swift
//  UI-694
//
//  Created by nyannyan0328 on 2022/10/09.
//

import SwiftUI

struct Home: View {
    @StateObject var model : DynamicProgress = .init()
    @State var sampleProgress : CGFloat = 0
    var body: some View {
      
        Button("\(model.isAdded ? "Stop" : "Start")Progress"){
            
            if model.isAdded{


            }
            else{
                
                let config = ProgressConfig(title: "ABC", progressImage: "arrow.up", expandedImage: "box.truck.badge.clock", tint: .yellow,rotationEnabled: true)
                
                
                model.addProgress(config: config)
                
           }
            
        }
        .padding(.top,90)
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            
            if model.isAdded{
                
                
                sampleProgress += 0.3
                
                model.updateProgress(to: sampleProgress / 100)
                
            }
            else{
                
                sampleProgress = 0
            }
        }
        .statusBarHidden(model.statusBar)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class DynamicProgress : NSObject,ObservableObject{
    
    @Published var isAdded : Bool = false
    
    @Published var statusBar : Bool = false
    
    
    func addProgress(config : ProgressConfig){
        
        if rootController().view.viewWithTag(1009) == nil{
            
            let swiftUIView = DynamicProgressView(config: config).environmentObject(self)
            
            let hostiongView = UIHostingController(rootView: swiftUIView)
            
            hostiongView.view.backgroundColor = .clear
            hostiongView.view.tag = 1009
            hostiongView.view.frame = screenSize()
            rootController().view.addSubview(hostiongView.view)
            
            
            isAdded = true
            
        }
        
    }
    
    func updateProgress(to : CGFloat){
        
        
        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_PROGRESS"), object: nil,userInfo: [
        
            "Progress" : to
        
        ])
    }
    
    func removeProgreessWithAnimations(){
        
        NotificationCenter.default.post(name: NSNotification.Name("REMOVE_ANIMATIONS"), object: nil)
        
    }
    
    func removeProgressView(){
        
        if let view = rootController().view.viewWithTag(1009){
            
            view.removeFromSuperview()
            isAdded = false
            
        }
    }
    
    
    func screenSize()->CGRect{
        
        
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return.zero}
        
        return window.screen.bounds
    }
    
    func rootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return .init()}
        
        guard let root = screen.windows.first?.rootViewController as? UIViewController else{return .init()}
        
        return root
        
    }
    
    
}


struct DynamicProgressView : View{
    @State var showProgressView : Bool = false
    
    var config : ProgressConfig
    
    @State var progress : CGFloat = 0
    
    @State var showAlretView : Bool = false
    
    @EnvironmentObject var model : DynamicProgress
    
    var body: some View{
        
        Canvas { cxt, size in
            cxt.addFilter(.alphaThreshold(min: 0.3,color: .black))
            cxt.addFilter(.blur(radius: 5.5))
            cxt.drawLayer { context in
                
                for index in [1,2]{
                    
                    if let resolvedImage = context.resolveSymbol(id: index){
                        
                        context.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: 11 + 18))
                    }
                    
                }
            }
            
        } symbols: {
            
            ProgressComponets()
                .tag(1)
            
            ProgressComponets(isCircle: true)
                .tag(2)
            
        }
        .overlay(alignment: .top) {
            
            ProgressView()
                .offset(y:10)
            
        }
        .overlay(alignment: .top) {
            
            
                CustomAlretView()
            
        }
        
        .ignoresSafeArea()
        .allowsTightening(false)
        .onAppear{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                
                showProgressView = true
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UPDATE_PROGRESS"))) { output in
            
            if let info = output.userInfo,let progress = info["Progress"] as? CGFloat{
                
                if progress < 1{
                    
                    self.progress = progress
                    if (progress * 100).rounded() == 100{
                        
                      
                        showProgressView = false
                        showAlretView = true
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            
                            model.statusBar = true
                            
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            
                            
                            showAlretView = false
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                
                                model.statusBar = false
                                
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                
                                
                                model.removeProgressView()
                                
                            }
                        }
                        
                    }
                  
                }
                
            }
            
            
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("REMOVE_ANIMATIONS"))) { _ in
            showProgressView = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                
                model.removeProgressView()
        
                
            }
        }

    }
    @ViewBuilder
    func CustomAlretView ()->some View{
        
        
        GeometryReader{
            
            let size = $0.size
            
            Capsule()
                .fill(.black)
                .frame(width:showAlretView ? size.width : 125 ,height: showAlretView ? size.height : 35)
                .overlay {
                    HStack(spacing: 13) {
                        
                        Image(systemName: config.expandedImage)
                            .symbolRenderingMode(.multicolor)
                            .font(.largeTitle)
                            .foregroundStyle(.red,.green,.orange)
                        
                        HStack(spacing: 6) {
                            
                            Text("Down Load")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(config.title)
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                        }
                        .lineLimit(1)
                        .contentTransition(.identity)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .offset(y:12)
                        
                        
                        
                    }
                    .padding(.horizontal,12)
                    .blur(radius: showAlretView ? 0 : 5)
                    .opacity(showAlretView ? 1 : 0)
                  
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            
            
        }
        .frame(height:65)
        .padding(.horizontal,18)
        .offset(y:showAlretView ? 11 : 12)
        .animation(.interactiveSpring(response: 0.6,dampingFraction: 0.6,blendDuration: 0.6).delay(showAlretView ? 0.35 : 0), value: showProgressView)
        
        
        
        
    }
    @ViewBuilder
    func ProgressView ()->some View{
        
        
        ZStack{
            
            let rotation = (progress > 1 ? 1 : (progress < 0 ? 0 : progress))
            
            
            Image(systemName: config.progressImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .fontWeight(.semibold)
                .frame(width: 12,height: 12)
                .foregroundColor(config.tint)
                .rotationEffect(.init(degrees: config.rotationEnabled ? Double(rotation * 360) : 0))
            
            
            ZStack{
                
                
                Circle()
                    .stroke(.white.opacity(0.25),lineWidth: 4)
                
                Circle()
                    .trim(from: 0,to: progress)
                    .stroke(config.tint, style: StrokeStyle(lineWidth: 3,lineCap: .round,lineJoin: .round))
                    .rotationEffect(.init(degrees: showProgressView ?  -90 : 0))
                
                
                
                
                
            }
             .frame(width: 23,height: 23)
                
            
            
        }
        .frame(width: 37,height: 37)
        .frame(width: 127,alignment: .trailing)
        .offset(x:showProgressView ? 50 : 0)
   
        .animation(.interactiveSpring(response: 0.6,dampingFraction: 0.6,blendDuration: 0.6), value: showProgressView)
    
        
        
    }
    @ViewBuilder
    func ProgressComponets(isCircle : Bool = false)-> some View{
        
        
        if isCircle{
            
            Circle()
                .fill(.black)
                .frame(width: 37,height: 37)
                .frame(width: 127,alignment: .trailing)
                .offset(x:showProgressView ? 50 : 0)
                .scaleEffect(showProgressView ? 1 : 0.55,anchor: .trailing)
                .animation(.interactiveSpring(response: 0.6,dampingFraction: 0.6,blendDuration: 0.6), value: showProgressView)
        }
        else{
            
            Capsule()
             .fill(.black)
             .frame(width: 126,height: 35)
             .offset(y:1)
        }
        
        
        
    }
}
