//
//  FileBrowserView.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/26/21.
//

import SwiftUI
// A struct to store exactly one workoout's data.
struct Workout: Identifiable {
    let id = UUID()
    let name: String
}

// A view that shows the data for one workout.
struct WorkoutRow: View {
    var workout: Workout
    @State private var showMap = false
    @ObservedObject var workouts : Workouts = Workouts()
    
    
    var body: some View {
        HStack{
            NavigationLink(
                destination: WorkoutView(showMap: $showMap, workoutFileName: workout.name), isActive: $showMap){

                Button(action: {
                    withAnimation{
                        showMap = true
                    }
                    

                    }) {
                        Text("\(workout.name)")
                            
                    }

                }
        }
        
        
    } //ends bodyView
}

struct FileBrowserView: View {
    
    @State var workoutFiles: [Workout] = []
    @ObservedObject var workouts : Workouts = Workouts()
    @State var showingList = false

    private func generateWorkoutList(){
        
        let fileNames: [String] = workouts.getDirectoryFiles()
        
        for f in fileNames {
            workoutFiles.append(Workout(name: f))
        }
        
    }
    
    var body: some View {
        
        Group {
            VStack(alignment: .leading) {
                List(workoutFiles){ file in
                    WorkoutRow(workout: file)
                        .listRowBackground(Color.green)
                        
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Saved Workouts").font(.headline)
                        }.padding()
                    }
                }
                Spacer()
            }
            
        }.onAppear{
            if !showingList {
                showingList = true
                generateWorkoutList()
            }
            
        }
//        Text("Show track recordings here! ")
//            .font(.title)
//            .bold()
//            .onAppear {
////                DispatchQueue.main.asyncAfter(deadline: .now() + 5){
////                    self.isShowing = false
////                }
////                fileNames = workouts.getDirectoryFiles()
//            }
    }
}

//struct FileBrowserView_Previews: PreviewProvider {
////    @Binding show = true
//    static var previews: some View {
//        FileBrowserView(isShowing: $show)
//    }
//}


