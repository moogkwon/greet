//
//  AllowDeviceViewController.swift
//  GriitChat
//
//  Created by leo on 15/07/2018.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class AllowDeviceViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate , TransMngLoginDelegate {
    
    @IBOutlet weak var imgGif: UIImageView!
    
    var isMic = false;
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var imgMic: UIImageView!
    
    
    var isCamera = false;
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var imgCamera: UIImageView!
    
    
    var isLocation = false;
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var imgLocation: UIImageView!
    
    var isNotification = false;
    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var imgNotification: UIImageView!
    
    
    @IBOutlet weak var btnGo: UIButton!
    
    let locationMgr = CLLocationManager();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let backView: GradientView = super.view as! GradientView;
        backView.setBackColors(colors: [UIColor.dodgerBlue.cgColor, UIColor.brightLightBlue.cgColor]);
        
        imgGif.loadGif(asset: "accessgif");
        
        imgGif.layer.cornerRadius = 20;
        imgGif.clipsToBounds = true;
        
        setBtnStyle(button: btnMic, image: imgMic, imgName: "mic", state: false);
        setBtnStyle(button: btnCamera, image: imgCamera, imgName: "camera", state: false);
        setBtnStyle(button: btnLocation, image: imgLocation, imgName: "location", state: false);
        setBtnStyle(button: btnNotification, image: imgNotification, imgName: "notification", state: false);
        
        btnGo.layer.cornerRadius = btnGo.frame.height / 2;
        btnGo.clipsToBounds = true;
        
        navigationController?.navigationBar.isHidden = true;
        navigationController?.setNavigationBarHidden(true, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBtnStyle(button: UIButton, image: UIImageView, imgName: String, state: Bool) {
        DispatchQueue.main.async {
            button.layer.cornerRadius = button.frame.height / 2;
            button.clipsToBounds = true;
            button.layer.borderColor = UIColor.white.cgColor;
            button.layer.borderWidth = 1;
            
            if (!state) {
                button.layer.backgroundColor = nil;
                button.setTitleColor(UIColor.white, for: .normal);
                image.image = UIImage(named: imgName + "_white");
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor;
                button.setTitleColor(UIColor.brightLightBlue, for: .normal);
                image.image = UIImage(named: imgName);
            }
            
            if (self.isMic && self.isCamera && self.isLocation && self.isNotification) {
                self.btnGo.backgroundColor = UIColor.white;
                self.btnGo.alpha = 1;
                self.btnGo.isEnabled = true;
            } else {
                self.btnGo.backgroundColor = UIColor.white;
                self.btnGo.alpha = 0.5;
                self.btnGo.isEnabled = false;
            }
        }
    }
    
    @IBAction func onBtnMic(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: .audio) { (granted: Bool) in
            if (granted) {
                self.isMic = true;
                self.setBtnStyle(button: self.btnMic, image: self.imgMic, imgName: "mic", state: self.isMic)
                DispatchQueue.main.async {
                    self.btnMic.isEnabled = false;
                }
            }
        };
    }
    
    
    @IBAction func onBtnCamera(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
            if (granted) {
                DispatchQueue.main.async {
                    self.isCamera = true;
                    self.setBtnStyle(button: self.btnCamera, image: self.imgCamera, imgName: "camera", state: self.isCamera)
                    self.btnCamera.isEnabled = false;
                }
            }
        };
    }
    
    @IBAction func onBtnLocation(_ sender: Any) {
        
        let status  = CLLocationManager.authorizationStatus()

        locationMgr.delegate = self;
        // 2
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        
        // 3
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        isLocation = true;
        setBtnStyle(button: btnLocation, image: imgLocation, imgName: "location", state: isLocation)
        self.btnLocation.isEnabled = false;
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            self.isLocation = true;
            self.setBtnStyle(button: self.btnLocation, image: self.imgLocation, imgName: "location", state: self.isLocation)
            self.btnLocation.isEnabled = false;
        }
    }
    
    @IBAction func onBtnNotification(_ sender: Any) {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            
            center.removeAllDeliveredNotifications();
            center.removeAllPendingNotificationRequests();
            center.delegate = self; //UIApplication.shared.delegate as! AppDelegate;
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil && granted {
                    DispatchQueue.main.async {
                        /*let settings = UIUserNotificationSettings(forTypes: [.sound, .alert, .badge], categories: nil)
                        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                        UIApplication.shared.registerForRemoteNotifications()
                        */
//                        UIApplication.shared.registerForRemoteNotifications()
                        
                        self.isNotification = true;
                        self.setBtnStyle(button: self.btnNotification, image: self.imgNotification, imgName: "notification", state: self.isNotification)
                        self.btnNotification.isEnabled = false;
                    }
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        /*
        
        //Delete in real device.
        isNotification = true;
        setBtnStyle(button: btnNotification, image: imgNotification, imgName: "notification", state: isNotification)
        btnNotification.isEnabled = false;*/
    }
    
    func registerNotificationAction() {
        let first = UNNotificationAction.init(identifier: "first", title: "Go", options: [])
        let category = UNNotificationCategory.init(identifier: "categoryIdentifier", actions: [first], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func scheduleNotification() {
        
        // Create a content
        let content = UNMutableNotificationContent.init()
        content.title = NSString.localizedUserNotificationString(forKey: "Congratulations!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "You can use Griitchat...", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "categoryIdentifier"
        
        // Create a unique identifier for each notification
        let identifier = UUID.init().uuidString
        
        // Notification trigger
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        
        // Notification request
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        
        // Add request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.content.categoryIdentifier == "categoryIdentifier" {
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print(response.actionIdentifier)
                completionHandler()
            case "first":
                print(response.actionIdentifier)
                completionHandler()
            default:
                break;
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //2
        completionHandler([.alert, .sound])
    }
    
    /*func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        debugPrint("token: ", token);
        
        debugPrint("deviceToken.description: ", deviceToken.description);
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            debugPrint("uuid: ", uuid);
        }
        UserDefaults.standard.setValue(token, forKey: "ApplicationIdentifier")
        UserDefaults.standard.synchronize()
        
        
        isNotification = true;
        setBtnStyle(button: btnNotification, image: imgNotification, imgName: "notification", state: isNotification)
        btnNotification.isEnabled = false;
    }*/
    
    
    @IBAction func onBtnGo(_ sender: Any) {
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
        btnGo.isEnabled = false;
    }
    
    // 1
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation();
        
        let currentLocation: CLLocation = locations.last!
        
        let lat = currentLocation.coordinate.latitude;
        let lng = currentLocation.coordinate.longitude;
        
        let geocoder = CLGeocoder();
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks: [CLPlacemark]?, error: Error?) in
            if (error == nil) {
                let placemark: CLPlacemark = (placemarks?.last)!;
                
                let city: String = placemark.locality!;
                let country: String = placemark.country!;
//                let adminArea: String = placemark.administrativeArea!;      //like CA
                let countryCode: String = placemark.isoCountryCode!;          //like US
                
//                placemark.isoCountryCode      =   US
                self.sendLocationInfo(city: city, country: country, countryCode: countryCode, locLat: String(lat), locLng: String(lng));
            } else {
                self.showMessage(title: "Get Location Error", content: (error?.localizedDescription)!, completion: {
                    self.btnGo.isEnabled = true;
                });
            }
        }
        
        print("Current location: \(currentLocation)")
        
        //Erase in Real device
//        sendLocationInfo(locStr: "Vladivostok, Russian Federation", locLat: String(lat), locLng: String(lng));
    }
    
    // 2
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        showMessage(title: "Location Error", content: error.localizedDescription);
        btnGo.isEnabled = true;
        locationMgr.stopUpdatingLocation();
    }
    
    func sendLocationInfo(city: String, country: String, countryCode: String, locLat: String, locLng: String) {
        Extern.transMng.loginDelegate = self;
        let result = Extern.transMng.sendMessage(msg: ["id": "setLocation",
                                          "city": city,
                                          "country": country,
                                          "country_code": countryCode,
                                          "location_lat": locLat,
                                          "location_lng": locLng]);
        if (!result) {
            showNetworkErrorMessage {
                self.btnGo.isEnabled = true;
            }
        }
    }
    
    func onSetLocation(result: Bool, message: String?) {
        if (result) {
            UserDefaults.standard.set(true, forKey: UserKey.IsAllowDevice);
            imgGif.remove();

            self.scheduleNotification();
            self.registerNotificationAction();
            
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController");
            self.navigationController?.pushViewController(mainVC!, animated: true);
        } else {
            showMessage(title: "Set Location Error", content: message!, completion: {
                self.btnGo.isEnabled = true;
            });
        }
    }
}
