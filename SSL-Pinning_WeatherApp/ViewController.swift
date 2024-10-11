//
//  ViewController.swift
//  SSL-Pinning_WeatherApp
//
//  Created by Ateeq Ahmed on 11/10/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getWeather()
    }
    
    func getWeather() {
        var url = URL.init(string: "https://api.openweathermap.org/data/2.5/weather")
        
        if #available(iOS 16.0, *) {
            url?.append(queryItems: [
                URLQueryItem.init(name: "lat", value: "24.45"),
                URLQueryItem.init(name: "lon", value: "54.37"),
                URLQueryItem.init(name: "units", value: "metric"),
                URLQueryItem.init(name: "appid", value: ""),
            ])
        } else {
            /*       https://api.openweathermap.org/data/2.5/weather?lat=28.7041&lon=77.1025&units=metric&appid=
             */
        }
        
        NetworkManager.shared.request(url: url, expecting: WeatherModel.self) { data, error in
            
            if let error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.cityNameLabel.text = data?.name
                
                self.minTempLabel.text = "\(data?.main.tempMin ?? 0.0)"
                self.maxTempLabel.text = "\(data?.main.tempMax ?? 0.0)"
            }
        }
    }

}

