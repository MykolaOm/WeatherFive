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

class ViewController: UIViewController {

    
//    let WEATHER_URL : String = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27vinnitsia%27)&format=json&%22"
    
    let firstUrlPart = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%27"
    var city : [String] = ["vinnitsia","kyiv"]
   
    let lastUrlPart = "%27)&format=json&%22"
    lazy var WEATHER_URL = "\(firstUrlPart)\(city[0])\(lastUrlPart)"
    @IBAction func buttonTaped(_ sender: UIButton) {
        print("button taped")
        getWeatherData(url: WEATHER_URL)
       
    }
    @IBAction func tapToRetrive(_ sender: UIButton) {
        addCity()
        retrieveCities()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("--\n---getWeather now ---\n---")
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
                
                print(weatherJSON)
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
        if let tempResult = json["query"]["lang"].string {
            let countIndex: Int = 7
            print(json["query"]["results"]["channel"]["location"]["city"].stringValue)
            print(json["query"]["results"]["channel"]["location"]["country"].stringValue)
            for item in 0..<countIndex {
                let farenhLow = json["query"]["results"]["channel"]["item"]["forecast"][item]["low"].stringValue
                let farenhHigh = json["query"]["results"]["channel"]["item"]["forecast"][item]["high"].stringValue
                let celsiumLow = temperatureConverter(temperature: farenhLow)
                let celsiumHigh = temperatureConverter(temperature: farenhHigh)
                let Day = json["query"]["results"]["channel"]["item"]["forecast"][item]["day"].stringValue
                let Date = json["query"]["results"]["channel"]["item"]["forecast"][item]["date"].stringValue
                 print("\nrow number\(item)\n")
                print("\(Day) \(Date)")
                print("min \(celsiumLow)")
                print("max \(celsiumHigh)")
               
//                print("min " + "\(json["query"]["results"]["channel"]["item"]["forecast"][item]["low"].stringValue)")
//            print("max" + "\(json["query"]["results"]["channel"]["item"]["forecast"][item]["high"].stringValue)")
                
            }
            print("in JSON succes!")
        }
        else {
            print( "Weather Unavailable")
        }
    }
    // MARK: CONVERTER
    /***************************************************************/
    func temperatureConverter(temperature: String)->Int {
        return Int(5.0/9.0 * (Double(temperature)! - 32))
    }
    
    // MARK: DB OPERATIONS
    /***************************************************************/
//
//    let messagesDB = Database.database().reference().child("Messages")
//
//    let messageDictionary = ["sender":Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
//
//    messagesDB.childByAutoId().setValue(messageDictionary){
//        (error, ref) in
//        if error != nil {
//            print(error!)
//        }
//        else {
//            print ("Message saved succesfully")
//
//            self.messageTextfield.isEnabled = true
//            self.sendButton.isEnabled = true
//
//            self.messageTextfield.text = ""
//        }
//    }
//
    
    // MARK --- observe dara from db firebase
    
    func addCity() {
        loginDB()
        let cityDB = Database.database().reference().child("city")
//        cityDB.child("0").setValue(["london"])
        cityDB.child("paris").setValue(["fr":"paris"])
        print("valueok")
    }
    func retrieveCities(){
//        loginDB()
        let cityDB = Database.database().reference().child("city").child("london")
        print(cityDB)
        cityDB.observeSingleEvent(of: .value) { (snapshot) in
            
            let snapshotValue = snapshot.value as? Dictionary<String, String>
            let cityNumber = snapshotValue!["uk"]!
            print(cityNumber)
            
        }
            
            
            
            
//            .observe(.childAdded, with:{ (snapshot) in
    
//        let snapshotValue = snapshot.value as! Dictionary<String, String>
//        let cityNumber = snapshotValue["0"]!
//
//        print(cityNumber)
//
//        let message = Message()
//        message.messageBody = text
//        message.sender = sender
//
//        self.messageArray.append(message)
//        self.configureTableView()
//        self.messageTableView.reloadData()
    
//        })
    }
    
    //---------------------------
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
    
//    @IBAction func logInPressed(_ sender: AnyObject) {
//
//
//
//        //TODO: Log in the user
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
    
    
    
    
    
}

