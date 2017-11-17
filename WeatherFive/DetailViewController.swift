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
    
    @IBOutlet weak var cityInfoLabel: UILabel!
    @IBOutlet weak var weekWeatherLabel: UILabel!
    
    @IBOutlet weak var changeAmount: UIButton!
    @IBOutlet weak var day1: UITextView!
    @IBOutlet weak var day2: UITextView!
    @IBOutlet weak var day3: UITextView!
    @IBOutlet weak var day4: UITextView!
    @IBOutlet weak var day5: UITextView!
    @IBOutlet weak var day6: UITextView!
    @IBOutlet weak var day7: UITextView!
    
    @IBOutlet weak var temperature1: UITextView!
    @IBOutlet weak var temperature2: UITextView!
    @IBOutlet weak var temperature3: UITextView!
    @IBOutlet weak var temperature4: UITextView!
    @IBOutlet weak var temperature5: UITextView!
    @IBOutlet weak var temperature6: UITextView!
    @IBOutlet weak var temperature7: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cityInfoLabel.text = cityInfodata
        
        changeAmount.setTitle("Show more", for: .normal)
        day4.isHidden = true
        day5.isHidden = true
        day6.isHidden = true
        day7.isHidden = true
        temperature4.isHidden = true
        temperature5.isHidden = true
        temperature6.isHidden = true
        temperature7.isHidden = true
      
           if  arrayOfWeekDays.count > 0 {
            day1.text = arrayOfDate[0] + separator + arrayOfWeekDays[0]
            day2.text = arrayOfDate[1] + separator + arrayOfWeekDays[1]
            day3.text = arrayOfDate[2] + separator + arrayOfWeekDays[2]
            day4.text = arrayOfDate[3] + separator + arrayOfWeekDays[3]
            day5.text = arrayOfDate[4] + separator + arrayOfWeekDays[4]
            day6.text = arrayOfDate[5] + separator + arrayOfWeekDays[5]
            day7.text = arrayOfDate[6] + separator + arrayOfWeekDays[6]
       
            temperature1.text = morningTemperature[0] + separator + nightTemperature[0]
            temperature2.text = morningTemperature[1] + separator + nightTemperature[1]
            temperature3.text = morningTemperature[2] + separator + nightTemperature[2]
            temperature4.text = morningTemperature[3] + separator + nightTemperature[3]
            temperature5.text = morningTemperature[4] + separator + nightTemperature[4]
            temperature6.text = morningTemperature[5] + separator + nightTemperature[5]
            temperature7.text = morningTemperature[6] + separator + nightTemperature[6]
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
        print("valueok")
    }
    
    func removeCity() {
        
        loginDB()
        let cityDB = Database.database().reference().child("city")
        cityDB.child(currentCity).removeValue()
        print("valueok")
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
        
        if day4.isHidden == true {
            changeAmount.setTitle("Show less", for: .normal)
            
            day4.isHidden = false
            day5.isHidden = false
            day6.isHidden = false
            day7.isHidden = false
            temperature4.isHidden = false
            temperature5.isHidden = false
            temperature6.isHidden = false
            temperature7.isHidden = false
        }
        else{
            changeAmount.setTitle("Show more", for: .normal)
            
            day4.isHidden = true
            day5.isHidden = true
            day6.isHidden = true
            day7.isHidden = true
            temperature4.isHidden = true
            temperature5.isHidden = true
            temperature6.isHidden = true
            temperature7.isHidden = true
        }
    }
    //LAST ROW IN CONTROLLER
}
