import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController{
    // Outlets connected to the storyboard elements
        @IBOutlet var rechercherText: UITextField!
        @IBOutlet var rechercherButton: UIButton!
        @IBOutlet var BouttonLocaliser: UIButton!
        @IBOutlet var LabelVille: UILabel!
        @IBOutlet var slider: UISlider!
        @IBOutlet var jour: UILabel!
        @IBOutlet var LabelDetails: UILabel!
        @IBOutlet var img: UIImageView!
        @IBOutlet var temperature: UILabel!
        @IBOutlet var subView: UIView!
        @IBOutlet var LabelHumidity: UILabel!
        @IBOutlet var LabelDirection: UILabel!
        @IBOutlet var LabelSpeed: UILabel!
        @IBOutlet var LabelClouds: UILabel!
        @IBOutlet var LabelHour: UILabel!
        @IBOutlet var loading: UIActivityIndicatorView!
        @IBOutlet var daysSlider: UISlider!
        @IBOutlet var LabelTomorrow: UILabel!
        @IBOutlet var LabelTomorrow2: UILabel!
        @IBOutlet var LabelTomorrow3: UILabel!
        @IBOutlet var LabelTomorrow4: UILabel!
        @IBOutlet var LabelTomorrow5: UILabel!
        @IBOutlet var LabelTomorrow6: UILabel!
        @IBOutlet var SlidersView: UIView!
    
    // Enhanced Gradient Background Colors

    // Daytime gradient: Vibrant blue transitioning into a bright cyan
    let colorTop = UIColor(red: 50.0/255.0, green: 120.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor

    // Nighttime gradient: Lighter transition for more visible depth
    let nightColorTop = UIColor(red: 30.0/255.0, green: 50.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
    let nightColorBottom = UIColor(red: 5.0/255.0, green: 15.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor

    var gradientLayer = CAGradientLayer()



    
    // Variables to hold weather and location data
    var city = "-"
    var temp = 0.0
    var desc = "-"
    var main = "-"
    var humidity = 0
    var windSpeed = 0
    var windDirection = 0
    var Clouds = 0
    var weathercode = 0
    var day = 1
    //date and time
    var date = Date()
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let formatterLabel = DateFormatter()
    var dateComponent = DateComponents()
    var heure = "00"
    var selectedDay = ""
    let cellReuseIdentifier = "cell"
    var datesOfWeek: [dates] = []
    //localisation
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    var latitude = 0.0
    var longitude = 0.0
    
    //API links
    let headers = ["accept": "application/json"]
    var request : NSMutableURLRequest!
    
    //let apiKey = "447f7934741432cb445ee548f553fa2c"
    struct dates {
        let long: String
        let numbers: String
        let short: String
    }

    // Initial setup for the view when it loads
    override func viewDidLoad() {
        
        super.viewDidLoad()
        localisation()
        self.actualiser(time: 2)
        self.hideSpinner()
        setGradientBackground()
        subView.layer.cornerRadius = 10
        
        
        // Ajoutez cette ligne
            updateBackgroundForTime(hour: Int(slider.value))
        
        // Date formatting for the current day
        let template = "EEEEdMMM"
        let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: NSLocale.current)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let now = Date()
        self.jour.text = formatter.string(from: now)
        
        // Prepare the week dates
        self.formatter.dateFormat = "yyyy-MM-dd"
        let formatterShort = DateFormatter()
        formatterShort.dateFormat = "MM/dd"
        self.selectedDay = self.formatter.string(from: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: now),numbers: formatter.string(from: now),short: formatterShort.string(from: now)))
        
        // Calculate the dates for the next 6 days
        self.dateComponent.day = 1
        let tomorrow = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow!),numbers: formatter.string(from: tomorrow!),short: formatterShort.string(from: tomorrow!)))
        self.dateComponent.day = 2
        let tomorrow2 = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow2!),numbers: formatter.string(from: tomorrow2!),short: formatterShort.string(from: tomorrow2!)))
        self.dateComponent.day = 3
        let tomorrow3 = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow3!),numbers: formatter.string(from: tomorrow3!),short: formatterShort.string(from: tomorrow3!)))
        self.dateComponent.day = 4
        let tomorrow4 = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow4!),numbers: formatter.string(from: tomorrow4!),short: formatterShort.string(from: tomorrow4!)))
        self.dateComponent.day = 5
        let tomorrow5 = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow5!),numbers: formatter.string(from: tomorrow5!),short: formatterShort.string(from: tomorrow5!)))
        self.dateComponent.day = 6
        let tomorrow6 = Calendar.current.date(byAdding: self.dateComponent, to: now)
        datesOfWeek.append(dates(long: self.formatter.string(from: tomorrow6!),numbers: formatter.string(from: tomorrow6!),short: formatterShort.string(from: tomorrow6!)))
        print(datesOfWeek)
        
        // Set the labels for tomorrow's dates
        LabelTomorrow.text = datesOfWeek[1].short
        LabelTomorrow2.text = datesOfWeek[2].short
        LabelTomorrow3.text = datesOfWeek[3].short
        LabelTomorrow4.text = datesOfWeek[4].short
        LabelTomorrow5.text = datesOfWeek[5].short
        LabelTomorrow6.text = datesOfWeek[6].short
        
        // Set the current hour label
               let hours = (Calendar.current.component(.hour, from: now))
               heure = (hours < 10) ? "0\(hours)" : "\(hours)"
               LabelHour.text = "\(heure):00"
               slider.value = Float(hours)
    }
    
    // Handles device orientation changes (portrait/landscape)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.layoutHorizontal()
                self.setGradientBackground()
            }
        } else {
            print("Portrait")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.layoutVertical()
                self.setGradientBackground()
            }
        }
    }
    
    // Set the gradient background for the view
    func setGradientBackground() {
        self.gradientLayer.colors = [self.colorTop, self.colorBottom]
        self.gradientLayer.locations = [0.0, 1.0]
        self.gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer, at:0)
    }
    
    func updateBackgroundForTime(hour: Int) {
        // Définir les heures de nuit (par exemple 19h à 6h)
        let isNightTime = hour >= 19 || hour < 6
        
        UIView.animate(withDuration: 0.5) {
            if isNightTime {
                self.gradientLayer.colors = [self.nightColorTop, self.nightColorBottom]
            } else {
                self.gradientLayer.colors = [self.colorTop, self.colorBottom]
            }
            self.gradientLayer.layoutIfNeeded()
        }
    }
    
    
    // Layout adjustments for portrait mode
    func layoutVertical(){
        img.frame.size.width = 150
        img.frame.origin.x = 125
        img.frame.origin.y = 280
        subView.frame.origin.x = 40
        subView.frame.origin.y = 440
        SlidersView.frame.origin.x = 40
        SlidersView.frame.origin.y = 600
    }
    
    // Layout adjustments for landscape mode
    func layoutHorizontal(){
        img.frame.size.width = 100
        img.frame.origin.x = 200
        img.frame.origin.y = 220
        subView.frame.origin.x = 450
        subView.frame.origin.y = 30
        SlidersView.frame.origin.x = 450
        SlidersView.frame.origin.y = 180
    }
    
    private func showSpinner() {
        loading.startAnimating()
        loading.isHidden = false
    }
    private func hideSpinner() {
        loading.stopAnimating()
        loading.isHidden = true
    }
    
    // Get the user's location
    func localisation() {
        LocationManager.shared.getUserLocation{ [weak self] location in DispatchQueue.main.async {
        guard let strongSelf = self else {
            return
        }
        strongSelf.map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
            LocationManager.shared.resolveLocationName(with: location) { [weak self] locationName in self?.city = locationName! }
        
        strongSelf.map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
            LocationManager.shared.resolveLocationLatitude(with: location) { [weak self] locationName in self?.latitude = Double(locationName!) }
            
        strongSelf.map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
            LocationManager.shared.resolveLocationLongitude(with: location) { [weak self] locationName in self?.longitude = Double(locationName!) }
        }
        }
    }
    
    //button localiser pressed
    @IBAction func localiser(_ sender: Any) {
        //self.showSpinner()
        
        if (self.latitude == 0.0 && self.longitude == 0.0){
            localisation()
        } else {
            localisation()
            self.showSpinner()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.hideSpinner()
                self.actualiser(time: 3)
            }
        }
    }
    
    //load data
    func actualiser(time : Int){
        /*
         self.request = NSMutableURLRequest(url: NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?q=\(C)&cnt=56&appid=\(self.apiKey)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
         */
        
        if (self.latitude == 0.0 && self.longitude == 0.0){
            self.LabelVille.text = "Position inconue"
            self.temperature.text = "-"
            self.LabelDetails.text = "-"
            self.LabelHumidity.text = "-"
            self.LabelSpeed.text = "-"
            self.LabelDirection.text = "-"
            self.LabelClouds.text = "-"
        } else {
            self.request = NSMutableURLRequest(url: NSURL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(self.latitude)&longitude=\(self.longitude)&hourly=temperature_2m,relativehumidity_2m,rain,snowfall,cloudcover,windspeed_10m,winddirection_10m,weathercode&timezone=auto&past_days=7")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0)
            self.request.httpMethod = "GET"
            self.request.allHTTPHeaderFields = self.headers
            self.getData()
                do {
                    sleep(UInt32(time))
                }
            self.LabelVille.text = self.city.uppercased()
            switch self.temp {
            case -0:
                self.temp = 0
                self.temperature.text = String(format: "%.0f", self.temp)
            default:
                self.temperature.text = String(format: "%.0f", self.temp)
            }
            
            switch self.weathercode {
                case 0:
                    if (Int(self.slider.value)<19 && Int(self.slider.value)>5){
                        self.img.image = UIImage(systemName: "sun.max.fill")
                    } else {
                        self.img.image = UIImage(systemName: "moon.fill")
                    }
                case 1, 2:
                    if (Int(self.slider.value)<19 && Int(self.slider.value)>5){
                        self.img.image = UIImage(systemName: "cloud.sun.fill")
                    } else {
                        self.img.image = UIImage(systemName: "cloud.moon.fill")
                    }
                case 3:
                self.img.image = UIImage(systemName: "cloud.fill")
                case 45, 48:
                self.img.image = UIImage(systemName: "cloud.fog.fill")
                case 51, 53, 55:
                self.img.image = UIImage(systemName: "cloud.drizzle.fill")
                case 56, 57:
                self.img.image = UIImage(systemName: "smoke.fill")
                case 61, 63, 65:
                self.img.image = UIImage(systemName: "cloud.rain.fill")
                case 66, 67:
                self.img.image = UIImage(systemName: "cloud.bolt.rain.fill")
                case 71, 73, 75:
                self.img.image = UIImage(systemName: "cloud.snow.fill")
                case 77:
                self.img.image = UIImage(systemName: "snow")
                case 80, 81, 82:
                self.img.image = UIImage(systemName: "cloud.heavyrain.fill")
                case 85, 86:
                self.img.image = UIImage(systemName: "wind.snow")
                case 95, 96, 99:
                self.img.image = UIImage(systemName: "cloud.bolt.fill")
                default:
                self.img.image = UIImage(systemName: "exclamationmark.icloud.fill")
            }
            switch self.weathercode {
            case 0:
                self.desc = "Clear sky"
                if (Int(self.slider.value)<19 && Int(self.slider.value)>5){
                    self.img.image = UIImage(systemName: "sun.max.fill")
                } else {
                    self.img.image = UIImage(systemName: "moon.fill")
                }
            case 1:
                self.desc = "Mainly clear"
                if (Int(self.slider.value)<19 && Int(self.slider.value)>5){
                    self.img.image = UIImage(systemName: "cloud.sun.fill")
                } else {
                    self.img.image = UIImage(systemName: "cloud.moon.fill")
                }
            case 2:
                self.desc = "Partly cloudy"
                if (Int(self.slider.value)<19 && Int(self.slider.value)>5){
                    self.img.image = UIImage(systemName: "cloud.sun.fill")
                } else {
                    self.img.image = UIImage(systemName: "cloud.moon.fill")
                }
            case 3:
                self.desc = "Overcast"
                self.img.image = UIImage(systemName: "cloud.fill")
            case 45:
                self.desc = "Fog"
                self.img.image = UIImage(systemName: "cloud.fog.fill")
            case 48:
                self.desc = "Depositing rime fog"
                self.img.image = UIImage(systemName: "cloud.fog.fill")
            case 51:
                self.desc = "Light drizzle"
                self.img.image = UIImage(systemName: "cloud.drizzle.fill")
            case 53:
                self.desc = "Moderate drizzle"
                self.img.image = UIImage(systemName: "cloud.drizzle.fill")
            case 55:
                self.desc = "Dense intensity drizzle"
                self.img.image = UIImage(systemName: "cloud.drizzle.fill")
            case 56:
                self.desc = "Light freezing drizzle"
                self.img.image = UIImage(systemName: "smoke.fill")
            case 57:
                self.desc = "Dense intensity freezing drizzle"
                self.img.image = UIImage(systemName: "smoke.fill")
            case 61:
                self.desc = "Slight rain"
                self.img.image = UIImage(systemName: "cloud.rain.fill")
            case 63:
                self.desc = "Moderate rain"
                self.img.image = UIImage(systemName: "cloud.rain.fill")
            case 65:
                self.desc = "Heavy intensity rain"
                self.img.image = UIImage(systemName: "cloud.rain.fill")
            case 66:
                self.desc = "Light freezing rain"
            case 67:
                self.desc = "Heavy intensity freezing rain"
            case 71:
                self.desc = "Slight snow fall"
            case 73:
                self.desc = "Moderate snow fall"
            case 75:
                self.desc = "Heavy intensity snow fall"
            case 77:
                self.desc = "Snow grains"
            case 80:
                self.desc = "Slight rain showers"
            case 81:
                self.desc = "Moderate rain showers"
            case 82:
                self.desc = "Violent rain showers"
            case 85:
                self.desc = "slight snow showers"
            case 86:
                self.desc = "heavy snow showers"
            case 95:
                self.desc = "Thunderstorm"
            case 96:
                self.desc = "Slight hail thunderstorm"
            case 99:
                self.desc = "Heavy hail thunderstorm"
            default:
                self.desc = "No description"
            }
            self.LabelDetails.text = self.desc
            self.LabelHumidity.text = String(self.humidity)
            self.LabelSpeed.text = String(self.windSpeed)
            self.LabelDirection.text = String(self.windDirection)
            self.LabelClouds.text = String(self.Clouds)
        }
    }
    //Open Meteo (best one)
    struct ResponseM: Codable{
        let latitude: Float
        let longitude: Float
        let generationtime_ms: Float
        let utc_offset_seconds: Float
        let timezone: String
        let timezone_abbreviation: String
        let elevation: Float
        let hourly_units: Hourly_units
        let hourly: Hourly
    }
    struct Hourly_units: Codable{
        let time: String
        let temperature_2m: String
        let relativehumidity_2m: String
        let rain: String
        let snowfall: String
        let cloudcover: String
        let windspeed_10m: String
        let winddirection_10m: String
    }
    struct Hourly: Codable{
        let time: [String]
        let temperature_2m: [Float]
        let relativehumidity_2m: [Float]
        let rain: [Float]
        let snowfall: [Float]
        let cloudcover: [Float]
        let windspeed_10m: [Float]
        let winddirection_10m: [Float]
        let weathercode: [Int]
    }
    //get data from API
    func getData(){
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if let data = data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            do {
            let res = try JSONDecoder().decode(ResponseM.self, from: data)
                //Open Meteo
                //let date = Date()
                //self.formatter.dateFormat = "yyyy-MM-dd"
                //let someDateTime = self.formatter.string(from: date)
                let time = "\(self.selectedDay)T\(self.heure):00"
                print(time)
                for i in 1...335 {
                    if (res.hourly.time[i] == time){
                        self.temp = Double(res.hourly.temperature_2m[i]).rounded(.towardZero)
                        self.weathercode = Int(res.hourly.weathercode[i])
                        self.humidity = Int(res.hourly.relativehumidity_2m[i])
                        self.windSpeed = Int(res.hourly.windspeed_10m[i])
                        self.windDirection = Int(res.hourly.winddirection_10m[i])
                        self.Clouds = Int(res.hourly.cloudcover[i])
                    }
                }
            } catch let error {
            print(error)
            }
          }
          else if (error != nil) {
            print(error as Any)
          }
        })
        dataTask.resume()
    }
    //slider for days
    @IBAction func slidervalues(_ sender: Any) {
        var value = Int(slider.value);
        value = (value - value % 1);
        slider.value = Float(value);
        
        switch slider.value {
        case 0:
            heure = "00"
        case 1,2,3,4,5,6,7,8,9:
            heure = "0\(Int(slider.value))"
        case 24:
            heure = "00"
        default:
            heure = String(Int(slider.value))
        }
        LabelHour.text = "\(heure):00"
        
        // Ajoutez cette ligne pour mettre à jour le fond
           updateBackgroundForTime(hour: Int(slider.value))
        
        actualiser(time: 0)
    }
    @IBAction func daysSliderValues(_ sender: Any) {
        var value = Int(daysSlider.value);
        value = (value - value % 1);
        daysSlider.value = Float(value);
        self.jour.text = self.datesOfWeek[Int(daysSlider.value)].numbers
        self.selectedDay = self.datesOfWeek[Int(daysSlider.value)].long
        self.actualiser(time: 0)
    }
    //search for a city
    //get coordonates
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    @IBAction func chercher(_ sender: Any) {
        //OpenWheather.org
        getCoordinateFrom(address: self.rechercherText.text!) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            // don't forget to update the UI from the main thread
            DispatchQueue.main.async {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                print(self.city, "lat : ", coordinate.latitude," lon : ", coordinate.longitude)
                self.getData()
            }
        }
        self.showSpinner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideSpinner()
            self.actualiser(time: 3)
        }
        self.city = rechercherText.text!
    }
    
}
//OpenWheather.org data structure
/*
struct Response: Codable{
    let cod: String
    let message: Int
    let cnt: Int
    let list: [List]
    let city: City
}
struct List: Codable{
    let dt: Int
    let main: Main
    let weather : [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Float
    let pop: Float
    let sys: Sys
    let dt_txt: String
}
struct Main: Codable{
    let temp: Float
    let feels_like: Float
    let temp_min: Float
    let temp_max: Float
    let pressure: Float
    let sea_level: Float
    let grnd_level: Float
    let humidity: Float
    let temp_kf: Float
}
struct Weather: Codable{
    let id: Float
    let main: String
    let description: String
    let icon: String
}
struct Clouds: Codable{
    let all: Float
}
struct Wind: Codable{
    let speed: Float
    let deg: Float
    let gust: Float
}
struct Sys: Codable{
    let pod: String
}
struct City: Codable{
    let id: Float
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Float
    let sunrise: Float
    let sunset: Float
}
struct Coord: Codable{
    let lat: Float
    let lon: Float
}*/
/* //Open Weather
let K = res.list[self.day].main.temp
let converse = K - 273.15
print(res.city.name)
print(res.list[self.day].main.temp)
print(converse)
//fetch data to global variables
self.temp = Double(converse).rounded(.towardZero)
self.desc = res.list[self.day].weather[0].description
self.main = res.list[self.day].weather[0].main
self.humidity = Double(res.list[self.day].main.humidity)
self.windSpeed = Double(res.list[self.day].wind.speed)
self.windDirection = Double(res.list[self.day].wind.deg)
self.Clouds = Double(res.list[self.day].clouds.all)
*/
//Tomorrow.io
/*
var urlTomorrow = "https://api.tomorrow.io/v4/weather/realtime?location=newyork&apikey=vCisgT2BFIxAieR8zienQugTEwFp8RaF"
struct Response: Codable{
    let data: Data!
    let location: Location!
}
struct Data: Codable { // or Decodable
    let time: String!
    let values: Values!
}
struct Values: Codable {
    let cloudBase: Float
    let cloudCeiling: Float!
    let cloudCover: Float!
    let dewPoint: Float!
    let freezingRainIntensity: Float!
    let humidity: Float!
    let precipitationProbability: Float!
    let pressureSurfaceLevel: Float!
    let rainIntensity: Float!
    let sleetIntensity: Float!
    let snowIntensity: Float!
    let temperature: Float!
    let temperatureApparent: Float!
    let uvHealthConcern: Float!
    let uvIndex: Float!
    let visibility: Float!
    let weatherCode: Float!
    let windDirection: Float!
    let windGust: Float!
    let windSpeed: Float!
}
struct Location: Codable {
    let lat: Float!
    let lon: Float!
    let name: String!
    let type: String!
}
func getData(){
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      if let data = data {
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
        do {
        let res = try JSONDecoder().decode(Response.self, from: data)
        print(res.data.values.temperatureApparent!)
        self.temp = Double(res.data.values.temperatureApparent).rounded(.towardZero)
        } catch let error {
        print(error)
        }
      }
      else if (error != nil) {
        print(error as Any)
      }
    })

    dataTask.resume()
}
*/
