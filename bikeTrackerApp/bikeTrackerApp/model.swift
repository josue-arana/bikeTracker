//
//  model.swift
//  bikeTrackerApp
//
//  Created by Josue Arana on 4/20/21.
//

import Foundation
import Combine
import CoreLocation
import MapKit
import SwiftUI
 
enum stopWatchMode {
    case running
    case stopped
    case paused
}


//File Structures
struct GPXPoint: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var time: Date
}

struct GPXSegment: Codable {
    var coords : [GPXPoint]
}

struct GPXTrack : Codable {
    var name : String
    var link : String
    var time : String
    var segments : [GPXSegment] = []
    var distance = ""
    var feetClimbed = "-"
}

struct GPXData : Codable {
    var json : Data?
}
 

struct Annotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

class StopWatch: ObservableObject {
    private var sourceTimer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "stopwatch.timer")
    private var counter: Int = 0
    
    @Published var stopWatchTime = "00:00:00" {
        didSet {
            self.update()
        }
    }
    
    var paused = true {
        didSet {
            self.update()
        }
    }
    
    func start() {
        self.paused = !self.paused
        
        guard let _ = self.sourceTimer else {
            self.startTimer()
            return
        }
        
        self.resumeTimer()
    }
    
    func pause() {
        self.paused = !self.paused
        self.sourceTimer?.suspend()
    }
     
    
    func reset() {
        self.stopWatchTime = "00:00:00"
        self.counter = 0
    }
    
    func update() {
        objectWillChange.send()
    }
    
    func isPaused() -> Bool {
        return self.paused
    }
    
    private func startTimer() {
        self.sourceTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict,
                                                          queue: self.queue)
        self.resumeTimer()
    }
    
    private func resumeTimer() {
        self.sourceTimer?.setEventHandler {
            self.updateTimer()
        }
        
        self.sourceTimer?.schedule(deadline: .now(),
                                   repeating: 0.01)
        self.sourceTimer?.resume()
    }
    
    private func updateTimer() {
        self.counter += 1
        
        DispatchQueue.main.async {
            self.stopWatchTime = StopWatch.convertCountToTimeString(counter: self.counter)
        }
    }
}

extension StopWatch {
    static func convertCountToTimeString(counter: Int) -> String {
        let millseconds = counter % 100
        var seconds = counter / 100
        var minutes = seconds / 60
        var hours = minutes / 60
        
//        if seconds > 59 {
//            seconds = seconds % 60
//        }
//
//        if minutes > 59 {
//            minutes = minutes % 60
//        }
//        if hours > 59 {
//            hours = minutes % 60
//        }
        
        if seconds > 59 {
            seconds = seconds % 60
        }
        
        if minutes > 59 {
            minutes = minutes % 60
        }
        if hours > 59 {
            hours = minutes % 60
        }
        
        var millsecondsString = "\(millseconds)"
        var secondsString = "\(seconds)"
        var minutesString = "\(minutes)"
        var hoursString = "\(hours)"

        
        if millseconds < 10 {
            millsecondsString = "0" + millsecondsString
        }
        
        if seconds < 10 {
            secondsString = "0" + secondsString
        }
        
        if minutes < 10 {
            minutesString = "0" + minutesString
        }
        if hours < 10 {
            hoursString = "0" + hoursString
        }
         
        
        
        
        
        
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
}

class LocationMarks: ObservableObject {
    
    @Published var marks: [Annotation]
    
    init() { 
        marks = []
    }
    
    func addMark(mark: CLLocationCoordinate2D){
        marks.append(Annotation(coordinate:mark))
    }
     
}

class Workouts : ObservableObject {
    
    @Published var storedWorkouts: [GPXTrack] = []
    @Published var gpxAnnotations: [Annotation] = []
    @Published var storedDistance: String = ""
    @Published var storedDuration: String = ""
    @Published var firstRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.03), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    private var pgxLocations: [CLLocationCoordinate2D] = []
    
    
    //Function to obtain the file names inside the local file directory
    func getDirectoryFiles() -> [String] {
        let url: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let items: [String] = try! FileManager.default.contentsOfDirectory(atPath: url!.path)
        
        return items
    }
    
    func getMapData(fileName: String) {
        
        var gpxData : GPXTrack = GPXTrack(name: "sample", link: "sample", time: "123", segments: [], distance: "0", feetClimbed: "0")

        //read file and save Data
        let url: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let file = url?.appendingPathComponent(fileName)
        
        
        //decode Data with json.decoder
        let decoder = JSONDecoder.init()
        
        if let data = FileManager.default.contents(atPath: file!.path) {
            if let ddata = try? decoder.decode(GPXTrack.self, from: data) {
                gpxData = ddata
            }}
        
        
        //store in GPXtrack, segent an points accordingly
        storedWorkouts.append(gpxData)
        storedDistance = gpxData.distance
        storedDuration = gpxData.time
        gpxAnnotations = []
        
        //filter data to generate annotations
        for seg in storedWorkouts[0].segments  {
            let gpxPt = seg.coords
            
            var coords : [CLLocationCoordinate2D] = []
            pgxLocations = []
            
            for gp in gpxPt {
                coords.append(CLLocationCoordinate2D(latitude: gp.latitude, longitude: gp.longitude))
                pgxLocations.append(CLLocationCoordinate2D(latitude: gp.latitude, longitude: gp.longitude))
            }
            
            
            //create new annotation for each coordinate
            for cd in coords{
                self.gpxAnnotations.append(Annotation(coordinate: cd))
            }
        }
        
        
        //Function to generate a region withing the given locations
        func bounds() -> MKCoordinateRegion {
            
            var minLat: CLLocationDegrees {
                var localMin = pgxLocations[0].latitude
                for coord in pgxLocations {
                    if coord.latitude < localMin {
                        localMin = coord.latitude
                    }
                }
                return localMin
            }
            
            var maxLat: CLLocationDegrees {
                
                var localMax = pgxLocations[0].latitude
                for coord in pgxLocations {
                    if coord.latitude > localMax {
                        localMax = coord.latitude
                    }
                }
                return localMax
            }
            var minLon: CLLocationDegrees {
                
                var localMin = pgxLocations[0].longitude
                for coord in pgxLocations {
                    if coord.longitude < localMin{
                        localMin = coord.longitude
                    }
                }
                return localMin
            }
            
            var maxLon: CLLocationDegrees {
                
                var localMax = pgxLocations[0].longitude
                for coord in pgxLocations {
                    if coord.longitude > localMax {
                        localMax = coord.longitude
                    }
                }
                return localMax
            }
            
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0.5*(minLat+maxLat),longitude: 0.5*(minLon+maxLon)),
                span: MKCoordinateSpan(latitudeDelta: 1.5*(maxLat-minLat),longitudeDelta: 1.5*(maxLon-minLon)))
            
        }
        
        //create a region based on max and min coordinates
        self.firstRegion =  bounds()
        
    }
    
    func getAnnotations(){
        
    }
}


 
//Location manager Code
class LocationManager: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    

    @Published var allLocations: [CLLocation] = []
    @Published var allAnnotations: [Annotation] = []
    @Published var storedWorkouts: [GPXTrack] = []
    @Published var trackingStatus = "off"
    @Published var distance = 0.0
    private var duration = ""
    
    private var trackData : GPXData = GPXData(json: nil)
    
    @Published var status: CLAuthorizationStatus? {
    willSet { objectWillChange.send() }
    }

    @Published var location: CLLocation? {
    willSet { objectWillChange.send() }
    }
    
//    @Published var firstLocation: CLLocation? {
//    willSet { objectWillChange.send() }
//    }

    @Published var placemark: CLPlacemark? {
    willSet { objectWillChange.send() }
    }
     

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func changeTrackingStatus(status: String){
        trackingStatus = status
    }
    
    func saveDuration(duration: String){
        self.duration = duration
    }
    
    
    func generateGPSTrack(){
        
        var segment : GPXSegment = GPXSegment(coords: [])
        var j = 0
        
        //Create GPX based on each location
        for i in allLocations {
            //generate a point for each coordinate
            let point: GPXPoint = GPXPoint(latitude: i.latitude, longitude: i.longitude, altitude: i.altitude, time: i.timestamp)
            //generate a segmentation with list of  points.
            segment.coords.append(point)
            j += 1
        }
        
        
        //generate date formater to name the file as the current datetime.
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd-MM-YY    HH:mm"
        let stringDate = timeFormatter.string(from: Date())
        let distanceMiles = String(format: "%.2f", distance)
        
        
        //generate track with list of segments.
        let track: GPXTrack = GPXTrack(name: distanceMiles + "(MI) on " + stringDate, link: "some link", time: duration, segments: [segment], distance: distanceMiles, feetClimbed: "0")
       
            
        //encode data to a special GPXData struct of type Data
        let encoder = JSONEncoder.init()
        trackData.json = try? encoder.encode(track)
        
        //Set file parameters
        let data = trackData.json!
        let url: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        //Create file and save it to Files using FileManager
        if let file = url?.appendingPathComponent(track.name){
            
            FileManager.default.createFile(atPath: file.path,contents: data,attributes: nil)
//            print("File path = \(file.path)")
            print("File created!")
        }
        
        self.trackingStatus = "off"
    }
    
    
    private func geocode() {
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
         if error == nil {
               self.placemark = places?[0]
             } else {
               self.placemark = nil
             }
        })
    }
    
}



extension LocationManager: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
        
        
        if self.trackingStatus == "in-progress" {
            self.allLocations.append(location)
            allAnnotations.append(Annotation(coordinate: location.coordinate))
            self.distance = location.distance(from: allLocations[0])
            self.distance = distance * 0.000621371
//            print("Dist: \(distance)")
        }
        
        if self.trackingStatus == "ended" {
            self.generateGPSTrack()
            allAnnotations = []
            distance = 0.0
            duration = ""
        }
           
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("LocationManager didUpdateLocations: numberOfLocation: \(locations.count)")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        
//
//        locations.forEach { (location) in
////          print("LocationManager didUpdateLocations: \(dateFormatter.string(from: location.timestamp)); \(location.coordinate.latitude), \(location.coordinate.longitude)")
//            print("LocationManager latitude: \(location.coordinate.latitude)")
//            print("LocationManager longitude: \(location.coordinate.longitude)")
////          print("LocationManager altitude: \(location.altitude)")
////          print("LocationManager floor?.level: \(location.floor?.level)")
////          print("LocationManager horizontalAccuracy: \(location.horizontalAccuracy)")
////          print("LocationManager verticalAccuracy: \(location.verticalAccuracy)")
////          print("LocationManager speedAccuracy: \(location.speedAccuracy)")
//          print("LocationManager speed: \(location.speed)")
////          print("LocationManager timestamp: \(location.timestamp)")
////          print("LocationManager courseAccuracy: \(location.courseAccuracy)") // 13.4
////          print("LocationManager course: \(location.course)")
//        }
//      }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("LocationManager didFailWithError \(error.localizedDescription)")
//        if let error = error as? CLError, error.code == .denied {
//           // Location updates are not authorized.
//          // To prevent forever looping of `didFailWithError` callback
//           locationManager.stopMonitoringSignificantLocationChanges()
//           return
//        }
//      }
}


