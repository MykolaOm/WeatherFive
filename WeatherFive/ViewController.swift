//
//  ViewController.swift
//  WeatherFive
//
//  Created by Nikolas Omelianov on 14.11.17.
//  Copyright © 2017 Nikolas Omelianov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {

    var userCitiesArray : [String] = ["Vinnitsia","Kyiv"]
    var morningTemperature : [String] = []
    var nightTemperature : [String] = []
    var arrayOfDate : [String] = []
    var arrayOfWeekDays : [String] = []
    var cityDescription : String = "Ukraine"
    var currentCity : String = "Vinnitsia"
    var weekDays = "Mon Tue Wed Thu Fri Sat Sun"
    var weatherForWeek = ""
    
    @IBOutlet weak var firstNightLabel: UILabel!
    @IBOutlet weak var firstDayLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var changeCityTextField: UITextField!
     @IBOutlet weak var cityPicker: UIPickerView!
    
    
    let firstUrlPart = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27"

    var city : [String] = ["Vinnitsia","Kyiv"]
   
    let lastUrlPart = "%27)&format=json&%22"
    
    //lazy var WEATHER_URL = "\(firstUrlPart)\(city[0])\(lastUrlPart)"
    
    var WEATHER_URL = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27vinnitsia%27)&format=json&%22"
    
   
    @IBAction func getWeatherPressed(_ sender: UIButton) {
        if changeCityTextField != nil {
            
            currentCity = changeCityTextField.text!
            WEATHER_URL = firstUrlPart + currentCity + lastUrlPart
            getWeatherData(url: WEATHER_URL)
//            updateLabel()
        }
    }
    
    // MARK: UIPickerView func
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return userCitiesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userCitiesArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print(userCitiesArray[row])
        
        WEATHER_URL = firstUrlPart + userCitiesArray[row] + lastUrlPart
        getWeatherData(url: WEATHER_URL)
//        retrieveCities()
        pickerView.reloadAllComponents()
    }
    
    func updateLabel(){
        cityLabel.text = currentCity
        print("updating LABEL!!!!!")
       firstDayLabel.text = morningTemperature[0]
       firstNightLabel.text = nightTemperature[0]
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        cityPicker.delegate = self
        cityPicker.dataSource = self
        

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ALAMOFIRE REQUEST
    /***************************************************************/
    
    func getWeatherData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                //print(weatherJSON)
                print("in alamofire succes!")
                
                self.updateWeatherData(json : weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                print("in alamofire FAIL!")
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json : JSON) {
        print("in JSON entered")
        if let checkCity = json["query"]["results"]["channel"]["location"]["city"].string {
            let countIndex: Int = 7
            print(checkCity)
            currentCity = checkCity
            
            //clear arrys before fill
            nightTemperature.removeAll()
            arrayOfDate.removeAll()
            arrayOfWeekDays.removeAll()
            morningTemperature.removeAll()
            
            //print(json["query"]["results"]["channel"]["location"]["city"].stringValue)
            cityDescription = json["query"]["results"]["channel"]["location"]["country"].stringValue
            print(cityDescription)
            print("that was country!")
            for item in 0..<countIndex {
                let farenhLow = json["query"]["results"]["channel"]["item"]["forecast"][item]["low"].stringValue
                let farenhHigh = json["query"]["results"]["channel"]["item"]["forecast"][item]["high"].stringValue
                nightTemperature.append(temperatureConverter(temperature: farenhLow))
                morningTemperature.append(temperatureConverter(temperature: farenhHigh))
                arrayOfWeekDays.append(json["query"]["results"]["channel"]["item"]["forecast"][item]["day"].stringValue)
                arrayOfDate.append(json["query"]["results"]["channel"]["item"]["forecast"][item]["date"].stringValue)
            }
            print("in JSON succes!")
        }
        else {
            print( "Weather Unavailable")
        }
        weekDays = ""
        for day in arrayOfWeekDays{
            weekDays += "\(day) "
        }
        concateTemperatures()
        updateLabel()
    }
    // MARK: CONVERTER
    /***************************************************************/
    func temperatureConverter(temperature: String)->String {
        return String(Int(round(5.0/9.0 * (Double(temperature)! - 32))))
    }
    
    // MARK: DB OPERATIONS
    /***************************************************************/

    
    // MARK --- observe dara from db firebase
    
    func addCity() {
        loginDB()
        let cityDB = Database.database().reference().child("city")
        cityDB.child("paris").setValue(["fr":"paris"])
        print("valueok")
    }
    
    //*--------------------------------------------------------*//
    
    func retrieveCities(){
        loginDB()
        let cityDB = Database.database().reference().child("city")
        var groupCity = [String]()
        cityDB.observe(.value, with:{
            snapshot in
            for item in snapshot.children{
                groupCity.append((item as AnyObject).key)
            }
            for city in groupCity {
                if self.userCitiesArray.contains(city){
                    continue
                }
                else{
                    self.userCitiesArray.append(city)
                }
            }
 
        })
        print(userCitiesArray)
    }
    
    //---------------------------

    func loginDB(){
        let emailFB = "test@gmail.com"
        let passwordFB = "123456"
    
        Auth.auth().signIn(withEmail: emailFB, password: passwordFB) { (user, error) in
            if error != nil {
                print(error!)
            }
            else{
                print("logn succesful")
            }
        }

    }
    
    
      //---------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendDataForwards"{
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.cityInfodata = "\(currentCity), \(cityDescription)"
            detailViewController.weatherForWeek = weatherForWeek
            detailViewController.weekDays = weekDays
            
        }
    }
    
    func concateTemperatures(){
        weatherForWeek = ""
        for item in morningTemperature{
            weatherForWeek += item
            weatherForWeek += " "
        }
        weatherForWeek += "\n"
        for item in nightTemperature{
            weatherForWeek += item
            weatherForWeek += " "
        }
    }
    //    @IBAction func logOutPressed(_ sender: AnyObject) {
        //
        //        //TODO: Log out the user and send them back to WelcomeViewController
        //        do {
        //            try Auth.auth().signOut()
        //        }
        //        catch{
        //            print("problem with logout")
        //        }
        //        guard (navigationController?.popToRootViewController(animated: true) != nil)
        //            else{
        //                print("No View Controllers to pop off")
        //                return
        //        }
        //
        //    }
        
        //---------------------------
        
        //
    
    
}

