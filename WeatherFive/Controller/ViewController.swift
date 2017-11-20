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

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{

    let weatherDataModel = WeatherDataModel()
    var retrievedCities  : [String] = []
    let celsius = "°"
    
    @IBOutlet weak var firstNightLabel: UILabel!
    @IBOutlet weak var firstDayLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var cityPicker: UIPickerView!
    @IBOutlet weak var getWeather: UIButton!
    
    let firstUrlPart = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27"

    var city : [String] = ["Vinnitsia","Kyiv"]
   
    let lastUrlPart = "%27)&format=json&%22"
    
    
    var WEATHER_URL = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27vinnitsia%27)&format=json&%22"
    
   
    @IBAction func getWeatherPressed(_ sender: UIButton) {
        if changeCityTextField != nil {
            
            weatherDataModel.currentCity = changeCityTextField.text!
            WEATHER_URL = firstUrlPart + weatherDataModel.currentCity + lastUrlPart
            getWeatherData(url: WEATHER_URL)
        }
    }
    
    // MARK: UIPickerView func
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return weatherDataModel.userCitiesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weatherDataModel.userCitiesArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print(weatherDataModel.userCitiesArray[row])
        
        WEATHER_URL = firstUrlPart + weatherDataModel.userCitiesArray[row] + lastUrlPart
        getWeatherData(url: WEATHER_URL)
        retrieveCities()
        pickerView.reloadAllComponents()
    }
    
    func updateLabel(){
        cityLabel.text = weatherDataModel.currentCity
        
       firstDayLabel.text = weatherDataModel.morningTemperature[0] + celsius
       firstNightLabel.text = weatherDataModel.nightTemperature[0] + celsius
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        cityPicker.delegate = self
        cityPicker.dataSource = self
        changeCityTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ALAMOFIRE REQUEST
    /***************************************************************/
    
    func getWeatherData(url: String) {
        let modifiedUrl = (url.replacingOccurrences(of: " ", with: "")).replacingOccurrences(of: "'", with: "")
        Alamofire.request(modifiedUrl, method: .get).responseJSON {
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
            weatherDataModel.currentCity = checkCity
            
            //clear arrys before fill
            weatherDataModel.nightTemperature.removeAll()
            weatherDataModel.arrayOfDate.removeAll()
            weatherDataModel.arrayOfWeekDays.removeAll()
            weatherDataModel.morningTemperature.removeAll()

            weatherDataModel.cityDescription = json["query"]["results"]["channel"]["location"]["country"].stringValue
            for item in 0..<countIndex {
                let farenhLow = json["query"]["results"]["channel"]["item"]["forecast"][item]["low"].stringValue
                let farenhHigh = json["query"]["results"]["channel"]["item"]["forecast"][item]["high"].stringValue
                weatherDataModel.nightTemperature.append(temperatureConverter(temperature: farenhLow))
                weatherDataModel.morningTemperature.append(temperatureConverter(temperature: farenhHigh))
                weatherDataModel.arrayOfWeekDays.append(json["query"]["results"]["channel"]["item"]["forecast"][item]["day"].stringValue)
                weatherDataModel.arrayOfDate.append(json["query"]["results"]["channel"]["item"]["forecast"][item]["date"].stringValue)
                weatherDataModel.arrayOfDate[item] = String(weatherDataModel.arrayOfDate[item].dropLast(4))
            }
            print("in JSON succes!")
            updateLabel()
        }
        else {
            print( "Weather Unavailable")
        }

        
    }
    // MARK: CONVERTER
    /***************************************************************/
    func temperatureConverter(temperature: String)->String {
        return String(Int(round(5.0/9.0 * (Double(temperature)! - 32))))
    }
    
    // MARK: DB OPERATIONS
    /***************************************************************/
    
    func retrieveCities(){
      
        loginDB()
        let cityDB = Database.database().reference().child("city")
        var groupCity = [String]()
        cityDB.observe(.value, with:{
            snapshot in
            self.retrievedCities.removeAll()
            for item in snapshot.children{
                groupCity.append((item as AnyObject).key)
            }
            self.weatherDataModel.userCitiesArray.removeAll()
            self.weatherDataModel.userCitiesArray.append("Vinnitsia")
            self.weatherDataModel.userCitiesArray.append("Kyiv")
            for city in groupCity {
                if self.retrievedCities.contains(city){
                    print("city already exist")
                    continue
                }
                else{
                    self.retrievedCities.append(city)
                }
            }
            self.weatherDataModel.userCitiesArray += self.retrievedCities
           
        })
       
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
    
    // MARK : Transfering data to second view
    //*************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendDataForwards"{
            let detailViewController = segue.destination as! DetailViewController

           detailViewController.weatherDataModel = weatherDataModel
            detailViewController.cityInfodata = weatherDataModel.currentCity + ", " + weatherDataModel.cityDescription
 
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeCityTextField.resignFirstResponder()
        print("textField works")
        getWeatherPressed(getWeather)
        return true
    }
    
  //LAST ROW IN CONTROLLER
}

