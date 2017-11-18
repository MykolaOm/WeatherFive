//
//  DetailViewController.swift
//  WeatherFive
//
//  Created by Nikolas Omelianov on 17.11.17.
//  Copyright © 2017 Nikolas Omelianov. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    var cityDescription = ""
    var currentCity = ""
    var cityInfodata = ""
    var morningTemperature : [String] = []
    var nightTemperature : [String] = []
    var arrayOfDate : [String] = []
    var arrayOfWeekDays : [String] = []
    let separator : String = "\n"
    let celsius = "°"
    
    @IBOutlet weak var cityInfoLabel: UILabel!
    @IBOutlet weak var weekWeatherLabel: UILabel!
    
    @IBOutlet weak var changeAmount: UIButton!

    @IBOutlet var collection:[UITextView]!
    @IBOutlet var collectionofDateTextViews:[UITextView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cityInfoLabel.text = cityInfodata
        
        changeAmount.setTitle("Show more", for: .normal)
        for item in 3..<7{
            collection[item].isHidden = true
            collectionofDateTextViews[item].isHidden = true
        }

      
           if  arrayOfWeekDays.count > 0 {
            for item in 0..<7{
            collection[item].text = arrayOfDate[item] + separator + arrayOfWeekDays[item]
           collectionofDateTextViews[item].text = morningTemperature[item] + celsius + separator + nightTemperature[item] + celsius
            }

        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCityButtonPressed(_ sender: UIButton) {
        addCity()
    }
    
    @IBAction func removeCityButonPressed(_ sender: UIButton) {
        removeCity()
    }
    
    @IBAction func changeDayAmountPressed(_ sender: UIButton) {
        changeDayAmount()
    }
    func addCity() {
        
        loginDB()
        let cityDB = Database.database().reference().child("city")
        cityDB.child(currentCity).setValue(["country":cityDescription])
    }
    
    func removeCity() {
        
        loginDB()
        let cityDB = Database.database().reference().child("city")
        cityDB.child(currentCity).removeValue()
    }
    
    func loginDB() {
        
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
   
    func changeDayAmount() {
        
        if collection[4].isHidden == true {
            changeAmount.setTitle("Show less", for: .normal)
            for item in 3..<7{
                collection[item].isHidden = false
                collectionofDateTextViews[item].isHidden = false
            }

        }
        else{
            changeAmount.setTitle("Show more", for: .normal)
           
            for item in 3..<7{
                collection[item].isHidden = true
                collectionofDateTextViews[item].isHidden = true
            }

        }
    }
    //LAST ROW IN CONTROLLER
}
