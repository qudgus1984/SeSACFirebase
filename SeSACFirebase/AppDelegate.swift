//
//  AppDelegate.swift
//  SeSACFirebase
//
//  Created by 이병현 on 2022/10/05.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let config = Realm.Configuration(schemaVersion: 3) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 { //DetailTodo, List 추가
                
            }
            
            if oldSchemaVersion < 2 { //EmbeddedObject 추가
                
            }
            
            if oldSchemaVersion < 3 { //DetailTodoㅇ[ deadline추가
                
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        
        
        
        
        
        
        //aboutRealmMigration()
        
        UIViewController.swizzleMethod() //왜 인스턴스가 아니라 타입으로 써야하는지
        
        FirebaseApp.configure()
        
        // 알림 시스템에 앱을 등록
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        // 메시지 대리자 설정
        Messaging.messaging().delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //토큰을 성공적으로 받았을 때 firebase에게 token정보를 보냄!!
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    
    //포그라운드 알림 수신: 로컬 / 푸시 동일
    //카카오톡: 도이님과 채팅방, 푸시마다 설정, 화면마다 설정 가능
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //Setting 화면에 있다면 포그라운드 푸시 띄우지 마라!
        guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        if viewController is SettingViewController {
            completionHandler([]) // SettingVC 일 때에는 아무것도 받지 않겠다 라는 의미!
        } else {
            //.banner, .list : iOS 14+
            completionHandler([.badge, .sound, .banner, .list])
        }
    }
    
    //푸시 클릭: 카카오톡 푸시 클릭 -> 카카오톡 푸시 온 채팅방으로 바로 이동
    //유저가 푸시를 클릭했을 때만 실행되는 메서드
    
    //특정 푸시를 클릭하면 특정 상세 화면으로 화면 전환
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("사용자가 푸시를 클릭했습니다.")
        
        print(response.notification.request.content.body)
        print(response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo[AnyHashable("sesac")] as? String == "project" {
            print("SeSAC Project")
        } else {
            print("NOTHING")
        }
        
        guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        print(viewController)
        
        // viewController가 VC 이면 SettingVC로 화면 전환을 해주세요!
        if viewController is ViewController {
            viewController.navigationController?.pushViewController(SettingViewController(), animated: true)
        }
        
        // viewController가 ProfileViewController 이면, SettingVC로 이동해주세요!
        if viewController is ProfileViewController {
            viewController.dismiss(animated: true) {
                guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
                
                if viewController is ViewController {
                    viewController.navigationController?.pushViewController(SettingViewController(), animated: true)
                }
            }
        }
        
        // viewController가 SettingVC 이면, VC로 이동해주세요!
        if viewController is SettingViewController {
            viewController.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    //토큰 갱신 모니터링 : 토큰 정보가 언제 바뀔까?
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}

extension AppDelegate {
    func aboutRealmMigration() {
        //deleteRealmIfMigrationNeeded: 마이그레이션이 필요한 경우 기존 렘 삭제
//        let config = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)

        //각각의 schemaVersion에 따른 대응을 해주어야 함
        let config = Realm.Configuration(schemaVersion: 6) { migration, oldSchemaVersion in
            //컬럼 단순 추가 삭제의 경우엔 별도 필요 코드 X
            if oldSchemaVersion < 1 { }
            
            if oldSchemaVersion < 2 { }
            
            if oldSchemaVersion < 3 {
                migration.renameProperty(onType: Todo.className(), from: "importance", to: "favorite")
            }
            
            if oldSchemaVersion < 4 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    guard let old = oldObject else { return }

                    new["userDescription"] = "안녕하세요 \(old["title"]!) 의 중요도는 \(old["favorite"]!)입니다"
                }
            }
            
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    new["count"] = 100
                }
            }
            
            //타입 변환
            if oldSchemaVersion < 6 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    guard let old = oldObject else { return }
                    
                    new["favorite"] = old["favorite"]
                    
                    new["favorite"] = old["favorite"] ?? 1.0
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config

    }
}
