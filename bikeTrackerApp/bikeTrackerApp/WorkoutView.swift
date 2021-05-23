//
//  WorkoutView.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/27/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct WorkoutView: View {
   
    //Variables
    @Binding var showMap : Bool
    @ObservedObject var workouts : Workouts = Workouts()
    @State var workoutFileName: String
    @State var showZoom = true
    let darkBlueC = Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
    let green = Color(red: 19 / 255, green: 209 / 255, blue: 92 / 255)
    
     
    //Local localization variables
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    
    @State private var mapAnnotations: [Annotation] = []
    @State private var figure = true
    @State private var distance = ""
    @State private var duration = ""
    
    func assignMapData(){
        self.region = workouts.firstRegion
        self.mapAnnotations = workouts.gpxAnnotations
        self.distance = workouts.storedDistance
        self.duration = workouts.storedDuration
    }
    
    
    var body: some View {
        
        return VStack(alignment: .center) {
                 
            
                
            HStack(alignment:.center){
                 
                VStack{
                    Text(duration)
                        .font(Font.system(size: 30, design: .rounded))
                        .foregroundColor(Color.white)
                    
                    Text("Duration")
                        .font(Font.system(size: 14, design: .rounded))
                        .foregroundColor(Color.white)
                }.padding()
                
                VStack{
                    Text(distance)
                        .font(Font.system(size: 30, design: .rounded))
                        .foregroundColor(Color.white)
                    
                    Text("Distance (MI)")
                        .font(Font.system(size: 14, design: .rounded))
                        .foregroundColor(Color.white)
                }.padding()
                
                
            }.onAppear{
                workouts.getMapData(fileName: workoutFileName)
                assignMapData()
            }
            
            HStack{
                Image(systemName: "bicycle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .offset(x:figure ? -170:180)
                        .animation(Animation.linear(duration: 3).repeatForever())
                
            }
            .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                        withAnimation(.easeIn(duration:2)){
                                figure.toggle()
                            }
                    }
            }
            
                
//                                .repeatForever(autoreverses: true))
                    
            
//            HStack(alignment: .bottom ){
//                VStack{
//                    Text("Duration: 15:39 ")
//                        .font(.subheadline)
//                    Text("Distance: 0.8 (MI)")
//                        .font(.subheadline)
//                }
//                .padding()
//                .foregroundColor(darkBlueC)
//                .background(Color.white)
//                .cornerRadius(8)
//            }
            
           Map(coordinateRegion: $region,
               annotationItems: mapAnnotations
            )
           { annotation in

                MapAnnotation(coordinate: annotation.coordinate) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 15, height: 15)

                    }
           }
           .edgesIgnoringSafeArea(.bottom)
           
              
        }
        .background(darkBlueC)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    
                    Text(workoutFileName).font(.headline)
                        
                }.padding()
            }
        }
            
        
//                        Button("zoom out") {
//                            withAnimation {
//                                region.span = MKCoordinateSpan(
//                                    latitudeDelta: 0.01,
//                                    longitudeDelta: 0.01
//                                )
//                            }
//                        }
//                        .foregroundColor(.black)
//                        .background(Color.white)
//                        .padding()
//                        .cornerRadius(8)
//                        .offset(  y:-90)
        
//                        Spacer()
        
         
    } //end Main View
}

//struct WorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutView()
//    }
//}
