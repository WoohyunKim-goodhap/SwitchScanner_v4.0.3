//
//  AlarmViewController.swift
//  switchPriceKana
//
//  Created by Woohyun Kim on 2021/02/06.
//  Copyright © 2021 Woohyun Kim. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase

class AlarmViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var searchedGame: UILabel!
    @IBOutlet var currentCurrencyAlarm: UILabel!
    @IBOutlet var currentPriceLabel: UILabel!
    @IBOutlet var targetCurrencyAlarm: UILabel!
    @IBOutlet var targetPriceTF: UITextField!
    @IBOutlet var alarmRequestButton: UIButton!
    
    
    @IBOutlet var selectedGame: UILabel!
    @IBOutlet var currentPrice: UILabel!
    @IBOutlet var TargetPrice: UILabel!
    
    
    var searchedGameTitle = ""
    var currentMinPriceLabel = ""
    var currentCurrency = ""
    
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmRequestButton.setTitle(LocalizaionClass.AVCLabels.alarmRequestButton, for: .normal)
        selectedGame.text = LocalizaionClass.AVCLabels.selectedGame
        currentPrice.text = LocalizaionClass.AVCLabels.currentPrice
        TargetPrice.text = LocalizaionClass.AVCLabels.TargetPrice
        
        targetPriceTF.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        searchedGame.text = gameTitelForChart
        currentCurrencyAlarm.text = currencyForAlarm
        currentPriceLabel.text = priceForAlarm
        targetCurrencyAlarm.text = currencyForAlarm
        
        
        // Do any additional setup after loading the view.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "1234567890,."
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func alarmRequestClicked(_ sender: Any) {
        
        if targetPriceTF.text?.isEmpty == false {
            guard let targetPrice = targetPriceTF.text else {return}
            db.child("Alarm Request").childByAutoId().setValue(["currency": "\(currencyForAlarm)", "game": "\(gameTitelForChart)", "price": "\(targetPrice)", "APNtoken": "\(userToken)", "FCMtoken": "\(userFCMToken)"])
          
            SCLAlertView().showSuccess("\(LocalizaionClass.AVCAlert.successHead)", subTitle: "\(LocalizaionClass.AVCAlert.successSub)")
        }else{
            SCLAlertView().showError("\(LocalizaionClass.AVCAlert.errorHead)", subTitle: "\(LocalizaionClass.AVCAlert.errorSub)")
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
