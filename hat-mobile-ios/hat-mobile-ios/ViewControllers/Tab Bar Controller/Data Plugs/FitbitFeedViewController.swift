/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import HatForIOS
import SwiftyJSON

// MARK: Class

internal class FitbitFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCredentialsProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tabIndicatorView: UIView!
    @IBOutlet private weak var activityLabelView: UIView!
    @IBOutlet private weak var othersLabelView: UIView!
    @IBOutlet private weak var sleepLabelView: UIView!
    
    // MARK: - Struct
    
    private struct FitbitFeed: Comparable {
        
        static func < (lhs: FitbitFeedViewController.FitbitFeed, rhs: FitbitFeedViewController.FitbitFeed) -> Bool {
            
            return lhs.date < lhs.date
        }
        
        static func == (lhs: FitbitFeedViewController.FitbitFeed, rhs: FitbitFeedViewController.FitbitFeed) -> Bool {
            
            return lhs.name == rhs.name && lhs.value == rhs.value && lhs.date == rhs.date && lhs.category == rhs.category
        }
        
        var name: String = ""
        var value: String = ""
        var category: String = ""
        var addedCategoryID: String = ""
        var date: Date = Date()
    }
    
    // MARK: - Variables
    
    var weightUnit: String = "Kg"
    var heightUnit: String = "cm"
    
    /// The filter index, based on the selectionIndicatorView
    private var filterBy: Int = 0
    
    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    
    private var tempFeedArray: [FitbitFeed] = []
    private var feedArray: [[FitbitFeed]] = []
    private var sections: [String] = []
    
    // MARK: - Auto generated functions

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.addGestures()
        
        self.getFitbitData()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: Constants.ImageNames.tealImage), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {

        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.feedArray[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.feedArray.count > indexPath.section && self.feedArray[indexPath.section].count > indexPath.row else {
            
            return tableView.dequeueReusableCell(withIdentifier: "fitbitCell", for: indexPath)
        }

        let fitbitFeedObject = self.feedArray[indexPath.section][indexPath.row]
        // if the name is mockDate then show the date label, else show the normal cells
        if fitbitFeedObject.name == "mockDate" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedDateCell", for: indexPath) as? FitbitDateTableViewCell else {
                
                return tableView.dequeueReusableCell(withIdentifier: "feedDateCell", for: indexPath)
            }
            
            cell.setDateInLabel(date: FormatterHelper.formatDateStringToUsersDefinedDate(
                date: fitbitFeedObject.date,
                dateStyle: .medium,
                timeStyle: .none))
            
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fitbitCell", for: indexPath) as? DataPlugDetailsTableViewCell else {
                
                return tableView.dequeueReusableCell(withIdentifier: "fitbitCell", for: indexPath)
            }
            
            cell.setTitleToLabel(title: fitbitFeedObject.name)
            cell.setDetailsToLabel(details: fitbitFeedObject.value)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard !self.feedArray[section].isEmpty else {
            
            return self.sections[section]
        }
        
        let item = self.feedArray[section][0]
        if item.name == "mockDate" || item.category == "sleep" {
            
            return self.sections[section]
        }
        
        return "\(self.sections[section]) - \(item.addedCategoryID)"
    }
    
    // MARK: - Add gestures
    
    /**
     Adds the gestures to the 3 UIViews in the selectionIndicatorView
     */
    private func addGestures() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterTableView(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(filterTableView(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(filterTableView(gesture:)))
        
        self.activityLabelView.addGestureRecognizer(tapGesture)
        self.sleepLabelView.addGestureRecognizer(tapGesture1)
        self.othersLabelView.addGestureRecognizer(tapGesture2)
    }
    
    // MARK: - Filter feed
    
    /**
     Filters the offers based on the index of the selectionIndicatorView
     
     - parameter filterBy: The index of the selectionIndicatorView
     */
    private func filterFeed(filterBy: Int) {
        
        let tempArray: [FitbitFeed] = self.tempFeedArray.filter({
            
            if filterBy == 0 && $0.category == "sleep" {
                
                return true
            } else if filterBy == 1 && $0.category == "activity" {
                
                return true
            } else if filterBy == 2 && $0.category != "sleep" && $0.category != "activity" {
                
                return true
            } else {
                
                return false
            }
        })
        
        self.enumerateFilterFeedArray(from: tempArray)
    }
    
    /**
     Filters the offers based on the index of the selectionIndicatorView
     
     - parameter gesture: The UITapGestureRecognizer that triggered this method
     */
    @objc
    func filterTableView(gesture: UITapGestureRecognizer) {
        
        func animation(index: Int) {
            
            let indicatorWidth = self.tabIndicatorView.frame.width
            
            if index == 0 {
                
                self.tabIndicatorView.frame = CGRect(
                    x: self.sleepLabelView.frame.midX - indicatorWidth / 2,
                    y: self.tabIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.tabIndicatorView.frame.height)
            } else if index == 1 {
                
                self.tabIndicatorView.frame = CGRect(
                    x: self.activityLabelView.frame.midX - indicatorWidth / 2,
                    y: self.tabIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.tabIndicatorView.frame.height)
            } else if index == 2 {
                
                self.tabIndicatorView.frame = CGRect(
                    x: self.othersLabelView.frame.midX - indicatorWidth / 2,
                    y: self.tabIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.tabIndicatorView.frame.height)
            }
            
            DispatchQueue.global().async {
                
                self.filterBy = index
                self.filterFeed(filterBy: index)
                //self.tableView.reloadData()
            }
        }
        
        AnimationHelper.animateView(
            self.tabIndicatorView,
            duration: 0.25,
            animations: {
                
                animation(index: (gesture.view?.tag)!)
            },
            completion: { _ in return }
        )
    }
    
    // MARK: - Get fitbit data
    
    /**
     Failed to download the feed
     
     - parameter error: The error received from hat during fetching of the feed
     */
    private func gettingDataFailed(error: HATTableError) {
        
        self.loadingView.removeFromSuperview()
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    /**
     Data bundle created, download data bundle
     
     - parameter success: The result of the request to create the data bundle
     */
    private func bundleCreated(success: Bool) {
        
        HATFitbitService.getFitbitData(
            userDomain: userDomain,
            userToken: userToken,
            success: gotFitbitData,
            fail: gettingDataFailed)
    }
    
    /**
     Parses fitbit feed in away I can easily work with
     
     - parameter dictionary: The JSON received from HAT
     */
    private func gotFitbitData(dictionary: Dictionary<String, JSON>) {
        
        for dict in dictionary where !dict.value.arrayValue.isEmpty {
            
            if dict.key == "sleep" {
                
                for item in dict.value.arrayValue {
                    
                    let tempSleep = item["data"].dictionaryValue
                    
                    guard let sleep: HATFitbitSleepObject = HATFitbitSleepObject.decode(from: tempSleep) else {
                        
                        break
                    }
                    
                    let timeInterval = TimeInterval(sleep.duration / 1000)
                    
                    var object = FitbitFeed()
                    object.name = "Hours"
                    object.value = timeInterval.stringTime
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                    
                    object.name = "In bed"
                    var date = HATFormatterHelper.formatStringToDate(string: sleep.startTime)
                    object.value = date!.getTimeOfDay()
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                    
                    object.name = "Wake up"
                    date = HATFormatterHelper.formatStringToDate(string: sleep.endTime)
                    object.value = date!.getTimeOfDay()
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                    
                    object.name = "Times awake"
                    object.value = String(describing: sleep.levels.summary.awake.count)
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                    
                    object.name = "Times restless"
                    object.value = String(describing: sleep.levels.summary.restless.count)
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                    
                    object.name = "Minutes awake/restless"
                    object.value = String(describing: sleep.levels.summary.restless.minutes + sleep.levels.summary.awake.minutes)
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: sleep.dateOfSleep)!
                    self.tempFeedArray.append(object)
                }
            } else if dict.key == "weight" {

                for item in dict.value.arrayValue {

                    let tempWeight = item["data"].dictionaryValue

                    guard let weight: HATFitbitWeightObject = HATFitbitWeightObject.decode(from: tempWeight) else {

                        break
                    }

                    var object = FitbitFeed()
                    object.name = "Weight"
                    object.value = "\(weight.weight) \(weightUnit)"
                    object.category = dict.key
                    object.date = HATFormatterHelper.formatStringToDate(string: weight.date)!
                    self.tempFeedArray.append(object)
                }
            } else if dict.key == "activity" {

                for item in dict.value.arrayValue {

                    let tempDailyActivity = item["data"].dictionaryValue

                    guard let activity: HATFitbitActivityObject = HATFitbitActivityObject.decode(from: tempDailyActivity) else {

                        break
                    }

                    var object = FitbitFeed()
                    let date = HATFormatterHelper.formatStringToDate(string: activity.originalStartTime)
                    
                    object.name = "Steps"
                    if activity.steps == nil {
                        
                        object.value = "0"
                    } else {
                        
                        object.value = String(describing: activity.steps!)
                    }
                    object.category = dict.key
                    object.addedCategoryID = activity.activityName
                    object.date = date!
                    self.tempFeedArray.append(object)
                    
                    object.name = "Calories"
                    object.value = String(describing: activity.calories)
                    object.category = dict.key
                    object.addedCategoryID = activity.activityName
                    object.date = date!
                    self.tempFeedArray.append(object)
                    
                    let timeInterval = TimeInterval(activity.duration / 1000)
                    
                    object.name = "Duration"
                    object.value = timeInterval.stringTime
                    object.category = dict.key
                    object.addedCategoryID = activity.activityName
                    object.date = date!
                    self.tempFeedArray.append(object)
                }
            }
        }
        
        self.sortFeed()
    }
    
    /**
     Sorts the feed received from hat
     */
    private func sortFeed() {
        
        DispatchQueue.global().async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            guard !weakSelf.tempFeedArray.isEmpty else {
                
                return
            }
            weakSelf.tempFeedArray = weakSelf.tempFeedArray.sorted(by: { (obj1, obj2) -> Bool in
                
                if obj1.date == obj2.date {
                    
                    if obj1.category > obj2.category {
                        
                        return true
                    } else {
                        
                        return false
                    }
                } else if obj1.date > obj2.date {
                    
                    return true
                } else {
                    
                    return false
                }
            })
            
            let firstFeedObject = weakSelf.tempFeedArray.first!
            var date = firstFeedObject.date
            var temp: [FitbitFeed] = []
            
            var object = FitbitFeed()
            object.name = "mockDate"
            object.category = firstFeedObject.category
            object.date = date
            temp.append(object)
            
            for item in weakSelf.tempFeedArray {
                
                if item.date != date {
                    
                    object.name = "mockDate"
                    object.date = item.date
                    object.category = item.category
                    temp.append(object)
                    date = item.date
                }
                
                temp.append(item)
            }
            
            weakSelf.tempFeedArray = temp
            
            weakSelf.filterFeed(filterBy: 0)
        }
    }
    
    private func enumerateFilterFeedArray(from: [FitbitFeed]) {
        
        self.feedArray.removeAll()
        self.sections.removeAll()
        
        var section: [FitbitFeed] = []
        var previousCategory: String = ""
        
        for (index, item) in from.enumerated() {
            
            if previousCategory == "" {
                
                previousCategory = item.category
                section.append(item)
            } else if previousCategory == item.category && item.name == "mockDate" {
                
                self.sections.append(previousCategory)
                self.feedArray.append(section)
                section.removeAll()
                section.append(item)
            } else if previousCategory == item.category && index != from.count - 1 {
                
                section.append(item)
            } else if previousCategory != item.category {
                
                self.sections.append(previousCategory)
                previousCategory = item.category
                self.feedArray.append(section)
                section.removeAll()
                section.append(item)
            } else if index == from.count - 1 {
                
                section.append(item)
                self.sections.append(previousCategory)
                previousCategory = item.category
                self.feedArray.append(section)
                section.removeAll()
            }
        }
        
        self.feedArray.insert([], at: 0)
        self.sections.insert("", at: 0)
        
        for (index, item) in self.feedArray.enumerated().dropFirst() {
            
            guard let first = item.first else {
                
                break
            }
            
            self.feedArray[index].removeFirst()
            self.feedArray[index - 1].append(first)
        }
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingView.removeFromSuperview()
            self?.tableView.reloadData()
        }
    }

    /**
     Fetch fitbig feed from hat
     */
    private func getFitbitData() {
        
        // create loading pop up screen
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 40, y: (self.tableView?.frame.midY)! - 15, width: 140, height: 35),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Getting fitbit feed...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        HATFitbitService.createBundleWithFeed(
            userDomain: userDomain,
            userToken: userToken,
            success: bundleCreated,
            fail: gettingDataFailed)
    }
}
