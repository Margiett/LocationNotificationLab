//
//  CreateNotificstionViewController.swift
//  LocalNotificationLab Feb 20
//
//  Created by Margiett Gil on 2/20/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import UIKit
protocol CreateNotificationControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificationController: CreateNotificstionViewController)
}

class CreateNotificstionViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    weak var delegate: CreateNotificationControllerDelegate?
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 0.5 // current time plus 5 seconds
    
    var hours = Int()
    var seconds = Int()
    var mintues = Int()
    var totaltime = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func createLocalNotification(){
        
        let content = UNMutableNotificationContent()
        content.title = titleTextField.text ?? "Not title"
        content.body = "local Notifications"
        content.subtitle = "timer local Notification"
        content.sound = .default
        
        let identifier = UUID().uuidString
        
        if let imaageURL = Bundle.main.url(forResource: "pursuit-logo", withExtension: "png") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imaageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("error with attachment \(error)")
            }
        } else {
            print("image resource could not be found")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error adding request: \(error)")
                
            } else {
                print("request was successfully added")
            }
        }
        
    }
    
    @IBAction func timer(_ sender: UIBarButtonItem) {
        createLocalNotification()
        delegate?.didCreateNotification(self)
        dismiss(animated: true)
    }



@IBAction func picker(_ sender: UIDatePicker){
    guard sender.date > Date() else { return }
    
    timeInterval = sender.date.timeIntervalSinceNow
}
}

extension CreateNotificstionViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 25
        } else if component == 1 {
            return 61
        } else if component == 2 {
            return 61
        }
        return totaltime
    }
}

extension CreateNotificstionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var hour = [String]()
        for num in 0...25 {
            hour.append(num.description)
        }
        var mintues = [String]()
        for numMin in 0...61 {
            mintues.append(numMin.description)
        }
        var seconds = [String]()
        for numSec in 0...61 {
            seconds.append(numSec.description)
        }
        switch component {
        case 0:
            if row == 0 {
            return "\(hour[row]) hours"
            } else {
        return hour[row]
    }
    case 1:
    if row == 0 {
     return "\(mintues[row]) min"
    } else {
    return mintues[row]
    }
        case 2:
            if row == 0 {
                return "\(seconds[row]) seconds"
            } else {
                return seconds[row]
            }
    default:
    if row == 0 {
    return "\(mintues) seconds"
    } else {
    return mintues[row]
    }
   
}
}


func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    switch component {
    case 0:
        hours = Int(row) * 3600
        timeInterval = TimeInterval(hours + mintues + seconds + totaltime)
    case 1:
        mintues = Int(row) * 60
        timeInterval = TimeInterval(hours + mintues + seconds + totaltime)
    case 2:
        seconds = Int(row) * 60
        timeInterval = TimeInterval(hours + mintues + seconds + totaltime)
    default:
        seconds = Int(row)
        timeInterval = TimeInterval(hours + mintues + seconds + totaltime)

    }
    print(totaltime)
}
}
