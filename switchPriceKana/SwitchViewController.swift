//
//  ViewController.swift
//  switchPriceKana
//
//  Created by Woohyun Kim on 2020/09/12.
//  Copyright © 2020 Woohyun Kim. All rights reserved.
//

import UIKit
import Kanna
import SCLAlertView
import Firebase
import Kingfisher

//[]블로그 내용과 같이 별도의 UItableviewcontroller를 만들어서 사용
//[]스위치 게임리스트를 가져오고, lowercase로 필터링 할 것


class SwitchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let db = Database.database().reference().child("searchHistory")

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var searchedGemeTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    var countryArray = [String]()
    var noDigitalCountryArray = [String]()
    var priceArray = [String]()
    var gameTitle: String = ""
    var totalGameList: [String] = Array()
    var selectDatas = [UserData]()

 
    // 각 테이블 별 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return noDigitalCountryArray.count
    }

    //각 테이블 별 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListCell else { return UITableViewCell()}
            cell.countryLabel.text = noDigitalCountryArray[indexPath.row]
            cell.priceLabel.text = priceArray[indexPath.row]
            cell.flagimg.image = UIImage(named: countryNames.key(from: noDigitalCountryArray[indexPath.row]) ?? "")
            return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //price cell 눌렀을 때
        let selectedData = UserData(recordTitle: gameTitle, recordCountryName: noDigitalCountryArray[indexPath.row], recordMinPrice: priceArray[indexPath.row])
        selectDatas.append(selectedData)
            performSegue(withIdentifier: "showRecord", sender: nil)
        
    }
        
    
    var countryPrice: [String: String] = [:]
    var array = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rvc = segue.destination as? RecordViewController {
            rvc.userDatas = selectDatas
        }
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
    }
}

class ListCell: UITableViewCell {
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet var flagimg: UIImageView!
}

class searchCell: UITableViewCell {
    @IBOutlet var matchTitle: UILabel!
}


extension SwitchViewController: UISearchBarDelegate {
    
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
      
    func search(term: String) {
            var titleUrl: String = ""
            let currency = "₩"
            let noEmptyWithloweredTerm = term.replacingOccurrences(of: " ", with: "+").lowercased()
        
            let myURLString = "https://eshop-prices.com/games?q=\(noEmptyWithloweredTerm)"
            let myURL = URL(string: myURLString)
            let myHTMLString = try? String(contentsOf: myURL!, encoding: .utf8)
            let preDoc = try? HTML(html: myHTMLString!, encoding: .utf8)
            
            for link in preDoc!.xpath("//a/@href") {
                if !link.content!.contains("https") {
                    titleUrl = link.content!
                }
            }
            let itemURLString = "https://eshop-prices.com/\(titleUrl)?currency=KRW"
            let itemURL = URL(string: itemURLString)!
            let itemHTMLString = try? String(contentsOf: itemURL, encoding: .utf8)
            let itemDoc = try? HTML(html: itemHTMLString!, encoding: .utf8)
            let itemDocBody = itemDoc!.body
        
            if let itemNodesForCountry = itemDocBody?.xpath("/html/body/div[1]/div[2]/div/h1/text()") {
                for item in itemNodesForCountry {
                    if let itemText = item.text{
                        gameTitle = itemText
                    }
                }
            }
            
            if let itemNodesForCountry = itemDocBody?.xpath("/html/body/div[2]/div[1]/table/tbody//td/text()") {
                for country in itemNodesForCountry {
                    if country.content!.count > 2 && !country.content!.contains("₩") {
                        let trimmedCountry = country.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                        countryArray.append(trimmedCountry)
                    }
                }
                noDigitalCountryArray = countryArray.filter { $0 != "Digital code available at Eneba" }
            }
            
            if let itemNodesForPrice2 = itemDocBody?.xpath("/html/body/div[2]/div[1]/table/tbody//div/text()") {
                for price in itemNodesForPrice2 {
                    let trimmedPrice = price.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedPrice.hasPrefix(currency){
                        priceArray.append(trimmedPrice)
                    }
                }
            }
            if let itemNodesForPrice1 = itemDocBody?.xpath("/html/body/div[2]/div[1]/table/tbody//td[4]/text()") {
                for price in itemNodesForPrice1 {
                    let trimmedPrice = price.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedPrice.hasPrefix(currency){
                        priceArray.append(trimmedPrice)
                    }
                }
            }
        
            if let itemImage = itemDocBody?.at_xpath("/html/body/div[1]/div[2]/picture/img/@src") {
                let url = URL(string: itemImage.content!)
                imgView.kf.setImage(with: url)
            }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let allowedCharacters = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890-\n "
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: text)
        
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {return}
        
        priceArray.removeAll()
        countryArray.removeAll()
        noDigitalCountryArray.removeAll()
    
        search(term: searchTerm)
        self.db.childByAutoId().setValue(searchTerm)
        
        searchedGemeTitle.text = gameTitle
        self.tableView.reloadData()
        
        if noDigitalCountryArray.count < 1 {
            SCLAlertView().showError("검색결과가 없습니다", subTitle: "게임명을 다시 확인해주세요")
        }
    }
}


        
