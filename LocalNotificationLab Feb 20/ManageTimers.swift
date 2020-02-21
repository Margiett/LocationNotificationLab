//
//  ViewController.swift
//  LocalNotificationLab Feb 20
//
//  Created by Margiett Gil on 2/20/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import UIKit

class ManageTimers : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var notifications = [UNNotificationRequest]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotification = PendingNotification()
    
    private var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        checkForNotificationAuthorization()
        loadNotifications()
        confirgureRefreshControl()
        center.delegate = self 
    }
    
    private func confirgureRefreshControl(){
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController, let createVC = navController.viewControllers.first as? CreateNotificstionViewController else {
            fatalError("could not downcast to CreateNotificationViewController")
        }
        createVC.delegate = self
    }
    @objc
    private func loadNotifications(){
        pendingNotification.getPendingNotifications { (request) in
            self.notifications = request
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    private func checkForNotificationAuthorization(){
        center.getNotificationSettings { (settings) in

        if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermission()
            }
        }
    }
    private func requestNotificationPermission(){
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            if granted {
                print("access was granted")
                
            } else {
                print("access denied")
            }
        }
    }
}
extension ManageTimers: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNotification(atIndexPath: indexPath)
            
        }
}
    private func removeNotification(atIndexPath indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let identifer = notification.identifier
        
        center.removePendingNotificationRequests(withIdentifiers: [identifer])
        
        notifications.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ManageTimers: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      //  completionHandler( .alert)
        completionHandler(.alert)
    }
}
extension ManageTimers: CreateNotificationControllerDelegate {
    func didCreateNotification(_ createNotificationController: CreateNotificstionViewController) {
        loadNotifications()
    }
}
