//
//  ContentView.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/20/21.
//

import SwiftUI
import CoreLocation
import MapKit
import UniformTypeIdentifiers
 

struct ContentView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var marks: LocationMarks
    @EnvironmentObject var stopWatch: StopWatch
    
    //Local visual variables
    @State private var isShowing = false
    @State private var isON = false
    @State private var showMap = true
    @State private var showMetrics = false
    @State private var status = "off"
    @State private var mainButton = "START WORKOUT"
    @State private var endedWorkoutAlert = false
    
    
    
    let darkBlueC = Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
    let green = Color(red: 19 / 255, green: 209 / 255, blue: 92 / 255)
    let purpleGray = Color(red: 211 / 255, green: 220 / 255, blue: 225 / 255, opacity: 0.3)
    let darkRed = Color(red: 50 / 255, green: 0 / 255, blue: 13 / 255)
      
    
    var body: some View {
         
        let speedVal = locationManager.location != nil ? locationManager.location!.speed : 0
          
        VStack{
                
                if(!showMap){
                    
                    VStack{
                        Text("Bike Tracker App")
                            .font(Font.system(size: 35, design: .rounded))
                            .foregroundColor(darkBlueC)
                        Text("By Josue Arana")
                            .font(Font.system(size: 20, design: .rounded))
                            .foregroundColor(darkBlueC)
                    }.padding()
                    Spacer().onAppear{
                        if(!showMetrics){
                            showMetrics.toggle()
                        }
                        
                    }
                    
                    
                    
                }
                
                if(showMap){
                    MapView().navigationBarTitle("").background(Color.white)
                }
                // ----------- SHOW METRICS & BUTTONS -----------
                VStack{
                    let speedVal = String(format: "%.2f", speedVal)
//                    let time = String(format: "%.1f", stopWatchManager.secondsElapsed)
//
//                    Text("Time: \(stopWatchManager.timer)")
                    
                    HStack(alignment:.center){
                            
                        Spacer()
                        //Map toggle
                        VStack{
                            Button(action: {
                                        withAnimation{
                                            showMap.toggle()
                                            if(showMetrics){
                                                showMetrics.toggle()
                                            }
                                        }
                                
                                    }) {
                                Image(systemName: showMap == false ? "location.slash.fill" : "map.fill")
                                            .padding(10)
                                            .frame(width: 50, height: 50, alignment: .center)
                                            .background(darkBlueC)
                                            .cornerRadius(50)
                                            .foregroundColor(Color.white)
                                            .padding(0)
                                    }
                        }
                        
                        
                        Spacer()
                        
                        //Duration View
                        VStack{
                            Text(stopWatch.stopWatchTime)
                                .font(Font.system(size: 35, design: .rounded))
                                .foregroundColor( darkBlueC)
                                
                            
                            Text("Duration")
                                .font(Font.system(size: 18, design: .rounded))
                                .foregroundColor(darkBlueC)
                        }.frame(width: 150, height: 75, alignment: .center)
                        Spacer()
                        
                        
                        // ----------- RECORDED WORKOUTS PAGE
                        VStack{
                            HStack(alignment: .center ){
                                
                                NavigationLink(
                                    destination: FileBrowserView(), isActive: $isShowing){
                                    
                                    
                                    Button(action: {
                                            // Function call
                                            isShowing = true
                                            
                                        }) {
                                            Image(systemName: "list.bullet")
                                                .padding(12)
                                                .frame(width: 50, height: 50, alignment: .center)
                                                .background(darkBlueC)
                                                .cornerRadius(50)
                                                .foregroundColor(.white)
                                                .padding(0)
                                        }
                                }
                                
                            }
                        }
                        Spacer()
                        
                        
                        
                        
                    }.padding(.top, 30)
                    
                    
                    //----------- Metrics button - chevron -----------
                    HStack(alignment:.center){
                        Button(action: {
                            withAnimation{
                                showMetrics.toggle()
                            }
                    
                        }) {
                            Image(systemName: showMetrics == false ? "chevron.down" : "chevron.up")
                                .padding(10)
                                .frame(width: 25, height: 25, alignment: .center)
                                .background(Color.white)
                                .cornerRadius(50)
                                .foregroundColor(darkBlueC)
                                .padding(0)
                        }
                        
                    }
                    
                    //----------- Statistics -----------
                    if (showMetrics) {
//                        VStack{
                            let distanceMi = String(format: "%.2f", locationManager.distance)
                            HStack(alignment:.center){
                                
                                VStack{
                                    Text("\(distanceMi)")
                                        .font(Font.system(size: 30, design: .rounded))
                                        .foregroundColor(darkBlueC)
                                    
                                    Text("Distance (MI)")
                                        .font(Font.system(size: 14, design: .rounded))
                                        .foregroundColor(darkBlueC)
                                }.padding(3)
                                
                                VStack{
                                    Text("\(speedVal)")
                                        .font(Font.system(size: 30, design: .rounded))
                                        .foregroundColor(darkBlueC)
                                    
                                    Text("Speed (MPS)")
                                        .font(Font.system(size: 14, design: .rounded))
                                        .foregroundColor(darkBlueC)
                                }.padding(3)
                                
                                
                            }.animation(.spring()).offset(y:-5)
//                            Text("(\(lat),\(lon))")
//                        }
                        
                    }
                    
                    
                    VStack{ //----------- START, PAUSE, CONTINUE, END BUTTON -----------
                        
                        HStack(alignment: .center ){
                                
                            VStack(alignment: .center) {
                                
                                //START, PAUSE AND CONTINUE BUTTON
                                Button(action: {
                                    withAnimation {
                                        endedWorkoutAlert = false
                                        switch(status){
                                            case "off":
                                                status = "in-progress"
                                                mainButton = "PAUSE"
                                                stopWatch.start()
                                                break
                                            case "in-progress":
                                                status = "paused"
                                                mainButton = "CONTINUE"
                                                stopWatch.pause()
                                                break
                                            case "paused":
                                                status = "in-progress"
                                                mainButton = "PAUSE"
                                                stopWatch.start()
                                                break
                                            default:
                                                status = "off"
                                                mainButton = "NEW WORKOUT"
                                                stopWatch.start()
                                                break
//
                                        }
                                        
                                        //start recording func
                                        locationManager.changeTrackingStatus(status: status)
                                        
                                    }
                                }) {
                                    HStack {
                                        
                                        
                                        Text(mainButton)
                                            .font(Font.system(size: 22, design: .rounded))
                                            .padding(0)
                                            
                                    }
                                    .frame(width: 225, height: 30)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .background(status == "off" || status == "paused" || status == "ended" ? green : Color.red)
                                    .cornerRadius(15)
                                        
                                }
                                
                                //When to show END WORKOUT button
                                if(status != "off" && status != "ended"){
                                    Button(action: {
                                        withAnimation {
                                            //start recording func
                                            status = "off"
                                            mainButton = "START WORKOUT"
                                            endedWorkoutAlert = true
                                            locationManager.saveDuration(duration:stopWatch.stopWatchTime)
                                            locationManager.changeTrackingStatus(status: "ended")
                                            
                                            if stopWatch.isPaused(){
                                                stopWatch.start()
                                            }
                                            stopWatch.reset()
                                            stopWatch.pause()
                                            
                                        }
                                    }) {
                                        HStack {
                                            Text("END WORKOUT")
                                                .font(Font.system(size: 22, design: .rounded))
                                                .padding(0)
                                                
                                        }
                                        .frame(width: 225, height: 30)
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(darkRed)
                                        .cornerRadius(15)
                                        
                                            
                                    }
                                }
                                
                            }
                            
                                
                        }
                            
                    }.padding()
                    .alert(isPresented: $endedWorkoutAlert) {
                        Alert(title: Text("Good Job!"), message: Text("Your workout has been saved. You can find it in your saved workouts"), dismissButton: .default(Text("Got it!")))
                    }
                    
                    
                }.offset(y:-70)
                Spacer()
                
            }.environmentObject(locationManager)
              
    }
}


struct HelloView: View {
   @Binding var isShowing: Bool
   var body: some View {
       Text("Show track recordings here! ")
           .font(.title)
           .bold()
           .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                   self.isShowing = false
               }
           }
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
