//
//  bikeTrackerAppApp.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/20/21.
//

import SwiftUI

@main
struct bikeTrackerAppApp: App {
    @StateObject var locationManager: LocationManager = LocationManager()
    @StateObject var marks: LocationMarks = LocationMarks()
    @ObservedObject var stopWatch = StopWatch()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                .environmentObject(locationManager)
                .environmentObject(marks)
                .environmentObject(stopWatch)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
