//
//  LocationView.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/20/21.
//

import SwiftUI
import Foundation
import CoreLocation

struct LocationView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
//        let coord = locationManager.location?.coordinate
//        let lat = coord?.latitude ?? 0
//        let lon = coord?.longitude ?? 0
        let heading = locationManager.location?.course ?? 0
        VStack {
                    HStack {
                        Text("New Workout")
                            .fontWeight(.semibold)
                            .font(Font.system(size: 20, design: .serif))
                            .padding(0)
                            .rotationEffect(Angle.degrees(heading))
                            .animation(.spring())
                        
//                        Image(systemName: "location.north")
//                                .resizable()
//                                .frame(width:20,height: 20)
                                 
                    }
                    .padding(12)
                    .foregroundColor(.white)
                    .background(Color(red: 69 / 255, green: 55 / 255, blue: 222 / 255))
                    .cornerRadius(20)
                    .rotationEffect(Angle.degrees(heading))
                    .animation(.spring())
                    
                        
                        //LinearGradient(gradient: Gradient(colors: [Color.primary, Color(red: 95 / 255, green: 191 / 255, blue: 194 / 255)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(20)
//                    .rotationEffect(.degrees(gamePressed ? 360 : 0))
                      
                
            }
        
            
             
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
