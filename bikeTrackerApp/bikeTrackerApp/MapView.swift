//
//  MapView.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/20/21.
//

import SwiftUI
import Foundation 
import CoreLocation
import MapKit

struct CustomShape: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let brs = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        let brc = CGPoint(x: rect.maxX - radius, y: rect.maxY - radius)
        let bls = CGPoint(x: rect.minX + radius, y: rect.maxY)
        let blc = CGPoint(x: rect.minX + radius, y: rect.maxY - radius)
        
        path.move(to: tl)
        path.addLine(to: tr)
        path.addLine(to: brs)
        path.addRelativeArc(center: brc, radius: radius,
          startAngle: Angle.degrees(0), delta: Angle.degrees(90))
        path.addLine(to: bls)
        path.addRelativeArc(center: blc, radius: radius,
          startAngle: Angle.degrees(90), delta: Angle.degrees(90))
        
        return path
    }
}


 

struct MapView: View {
    
    //Enviroment/observed variables
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var marks: LocationMarks
    
    //Local visual variables
    @State var showZoom = false
    let darkBlueC = Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
    let green = Color(red: 19 / 255, green: 209 / 255, blue: 92 / 255)
    
     
    //Local localization variables
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.03), latitudinalMeters: 300, longitudinalMeters: 300
    )
          
    
    var body: some View {
        
        return VStack {
            
             
               Map(coordinateRegion: $region,
                   showsUserLocation: true,
                   userTrackingMode: .constant(.follow),
                   annotationItems: locationManager.allAnnotations
                )
               { annotation in
                    
                    MapAnnotation(coordinate: annotation.coordinate) {
//                         RoundedRectangle()
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)

                        }
               }
                .frame(height: 500)
                .mask(CustomShape(radius: 15))
               .shadow(color: locationManager.trackingStatus == "off" ? Color.gray:  locationManager.trackingStatus == "in-progress" ? Color.green : locationManager.trackingStatus == "paused" ? Color.red : Color.gray, radius: 15, x: 0, y: 7)
                .edgesIgnoringSafeArea(.top)
               
                  
                // ----------- Zoom buttons
                if showZoom {
                    HStack{
                        Spacer()
                        Button("zoom out") {
                            withAnimation {
                                region.span = MKCoordinateSpan(
                                    latitudeDelta: region.span.latitudeDelta + 1  ,
                                    longitudeDelta: region.span.longitudeDelta + 1
                                )
                            }
                        }.offset( y:-90)
                        
                        Spacer()
                        Button("zoom in") {
                            withAnimation {
                                region.span = MKCoordinateSpan(
                                    latitudeDelta: 0.01,
                                    longitudeDelta: 0.01
                                )
                            }
                        }.offset(  y:-90)
                        Spacer()
                    }
                }
            
        }
        
         
    }
     
}
extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
}
 
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
