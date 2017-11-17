//
//  DetailViewController.swift
//  WeatherFive
//
//  Created by Nikolas Omelianov on 17.11.17.
//  Copyright © 2017 Nikolas Omelianov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var cityInfodata = ""
    var weatherForWeek = ""
    var weekDays = ""
    
    @IBOutlet weak var cityInfoLabel: UILabel!
    @IBOutlet weak var weekWeatherLabel: UILabel!
    
    @IBOutlet weak var detailTextFildView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cityInfoLabel.text = cityInfodata
       detailTextFildView.text = "\(weekDays) \n\(weatherForWeek)"
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCityButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func removeCityButonPressed(_ sender: UIButton) {
    }
    
    
}
