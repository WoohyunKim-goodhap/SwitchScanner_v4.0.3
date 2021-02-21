//
//  ViewController.swift
//  switchPriceKana
//
//  Created by Woohyun Kim on 2020/09/12.
//  Copyright © 2020 Woohyun Kim. All rights reserved.
//

//[l localString에 avc에 있는 텍스트들 번역하기


import UIKit
import Kanna
import SCLAlertView
import Firebase
import Kingfisher
import GoogleMobileAds
import UserNotifications



class SwitchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
        
    var db: DatabaseReference!

    let center = UNUserNotificationCenter.current()


    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var searchedGemeTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var menuViewContraints: NSLayoutConstraint!
    @IBOutlet var MoveChart: UIButton!
    @IBOutlet var chartLabel: UIButton!
    @IBOutlet var alarmLabel: UIButton!
    @IBOutlet var alarmButton: UIButton!
    
    

    @IBAction func menuButtonPressed(_ sender: Any) {
        if menuView.isHidden == true{
            menuView.isHidden = false
//            showAnimation()
        }else {
            menuView.isHidden = true
//            prepareAnimation()
        }
    }
    
    
    private func prepareAnimation(){
        menuViewContraints.constant = 5
    }
    
    private func showAnimation(){
        menuViewContraints.constant = 2
        UIView.animate(withDuration: 0.3) {self.view.layoutIfNeeded()}
    }

    var countryArray = [String]()
    var noDigitalCountryArray = [String]()
    var priceArray = [String]()
    var trimmedPriceArray = [String]()
    var gameTitle: String = "?"
    var totalGameList: [String] = Array()
    var selectDatas = [UserData]()
    var currency = "USD"
    
    var countryPrice: [String: String] = [:]
    var array = [String]()

    /// The rewarded video ad.
    var rewardedAd: GADRewardedAd?

    
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
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference()

        prepareAnimation()
        searchBar.placeholder = LocalizaionClass.Placeholder.searchBarPlaceholder
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 13)

        //RewardAD
        rewardedAd = createAndLoadRewardedAd()

        
        //bannerAD
 
//        var bannerView: GADBannerView!
//        
//        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        bannerView.delegate = self
//        addBannerViewToView(bannerView)

        
        //addbannerviewto...없음
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      if #available(iOS 11.0, *) {
        // In iOS 11, we need to constrain the view to the safe area.
        positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
      }
      else {
        // In lower iOS versions, safe area is not available so we use
        // bottom layout guide and view edges.
        positionBannerViewFullWidthAtBottomOfView(bannerView)
      }
    }

    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
      // Position the banner. Stick it to the bottom of the Safe Area.
      // Make it constrained to the edges of the safe area.
      let guide = view.safeAreaLayoutGuide
      NSLayoutConstraint.activate([
        guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
        guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
        guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
      ])
    }

    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
      view.addConstraint(NSLayoutConstraint(item: bannerView,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: 0))
      view.addConstraint(NSLayoutConstraint(item: bannerView,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: 0))
      view.addConstraint(NSLayoutConstraint(item: bannerView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: bottomLayoutGuide,
                                            attribute: .top,
                                            multiplier: 1,
                                            constant: 0))
    }

    //GADBannerViewDelegate 메소드
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
        //화면에 베너뷰를 추가
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        menuView.isHidden = true
        prepareAnimation()
        
        //검색된 game이 있을 때만 chart이동 버튼 노출
        if searchedGemeTitle.text?.isEmpty == false {
            MoveChart.isHidden = false
            chartLabel.isHidden = false
            alarmLabel.isHidden = false
            alarmButton.isHidden = false
            
        }else{
            MoveChart.isHidden = true
            chartLabel.isHidden = true
            alarmLabel.isHidden = true
            alarmButton.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rvc = segue.destination as? RecordViewController {
            rvc.userDatas = selectDatas
        }
        
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
    }
    
    @IBAction func alarmButtonTapped(_ sender: Any) {
        
        if rewardedAd?.isReady == true{
           rewardedAd?.present(fromRootViewController: self, delegate:self)
        }
       
    }
}

//GADRewardAD
extension SwitchViewController: GADRewardedAdDelegate{
    

    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
      print("Rewarded ad presented.")
    }
    /// Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
         createAndLoadRewardedAd()
      print("Rewarded ad dismissed.")
    }
    /// Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
      print("Rewarded ad failed to present.")
    }
    
    
    func createAndLoadRewardedAd() -> GADRewardedAd{
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-8456076322553323/4330366365")
        rewardedAd?.load(GADRequest()) { error in
        if let error = error {
          print("Loading failed: \(error)")
        } else {
          print("Loading Succeeded")
        }
      }
        return rewardedAd!
    }
    

}


class ListCell: UITableViewCell {
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet var flagimg: UIImageView!
}



//search 관련 구문
extension SwitchViewController: UISearchBarDelegate {
    
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
      
    func search(term: String) {
            getCountryNames()
            var titleUrl = [String]()
            let noEmptyWithloweredTerm = term.replacingOccurrences(of: " ", with: "+").lowercased()
        
            let myURLString = "https://eshop-prices.com/games?q=\(noEmptyWithloweredTerm)"
            guard let addPercentURL = myURLString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else { return }
            guard let myURL = URL(string: addPercentURL) else {return}
            let myHTMLString = try? String(contentsOf: myURL, encoding: .utf8)
            let preDoc = try? HTML(html: myHTMLString!, encoding: .utf8)
            
            for link in preDoc!.xpath("//a/@href") {
                if !link.content!.contains("https") {
                    titleUrl.removeAll()
                    titleUrl.append(link.content!)
                }
            }
            guard let firstUrl = titleUrl.first else { return }
            let itemURLString = "https://eshop-prices.com/\(firstUrl)?currency=\(currency)"
            guard let itemURL = URL(string: itemURLString) else {return}
            selectedUrl = itemURL
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
                    if country.content!.count > 0 {
                        let trimmedCountry = country.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                        if onlyCountryNames.contains(trimmedCountry){
                            countryArray.append(trimmedCountry)
                        }
                    }
                }
                noDigitalCountryArray = countryArray.filter { $0 != "Digital code available at Eneba" }
            }
            trimmedPriceArray.removeAll()

            if let discountedPrice = itemDocBody?.xpath("/html/body/div[2]/div[1]/table/tbody//div/text()") {
                for price in discountedPrice{
                    let trimmedPrice = price.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                    trimmedPriceArray.append(trimmedPrice)
                }
                let onlyPriceArray = trimmedPriceArray.filter{ $0 != "List continues after this ad" && $0 != "" }
                priceArray.append(contentsOf: onlyPriceArray)
            }
            if let originalPrice = itemDocBody?.xpath("/html/body/div[2]/div[1]/table/tbody//td[4]/text()") {
                for price in originalPrice{
                    let trimmedPrice = price.content!.trimmingCharacters(in: .whitespacesAndNewlines)
                    trimmedPriceArray.append(trimmedPrice)
                }
                let onlyPriceArray = trimmedPriceArray.filter{ $0 != "List continues after this ad" && $0 != "" }
                priceArray.append(contentsOf: onlyPriceArray)

            }
        
            if let itemImage = itemDocBody?.at_xpath("/html/body/div[1]/div[2]/picture/img/@src") {
                if let itemContent = itemImage.content{
                    guard let url = URL(string: itemContent) else { return }
                    self.imgView.reloadInputViews()
                    imgView.kf.setImage(with: url)
                }

            }
        priceForAlarm = priceArray[0]
        titleForAlarm = gameTitle
        currencyForAlarm = currency
        print("titleForAlarm\(titleForAlarm)")
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
        
        searchedGemeTitle.text = gameTitle
        gameTitelForChart = gameTitle
        self.tableView.reloadData()
        
        if noDigitalCountryArray.count < 1 {
            SCLAlertView().showError("\(LocalizaionClass.SCalertText.error)", subTitle: "\(LocalizaionClass.SCalertText.errorDetail)")
        }
    }
}

extension String {
    func onlyNumbers() -> [NSNumber] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let charset = CharacterSet.init(charactersIn: " ,")
        return matches(for: "[+-]?([0-9]+([., ][0-9]*)*|[.][0-9]+)").compactMap { string in
            return formatter.number(from: string.trimmingCharacters(in: charset))
        }
    }
    
    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            return String(self[range])
        }
    }
}





        
