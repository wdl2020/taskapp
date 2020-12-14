//
//  InputViewController.swift
//  taskapp
//
//  Created by HY on 2020/12/09.
//  Copyright © 2020 HY. All rights reserved.
//

import UIKit
// レルム
import RealmSwift
// 通知機能
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    // レルムインスタンス
    let realm = try! Realm()

    // タスクインスタンス
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))

        self.view.addGestureRecognizer(tapGesture)

        // 遷移元からのデータを表示
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
        
        // 文字入力時に1文字目が大文字に変換されないようにする
        titleTextField.autocapitalizationType = .none
        contentsTextView.autocapitalizationType = .none
        categoryTextField.autocapitalizationType = .none
        
        // 文字入力時の補正機能を無効にする
        titleTextField.autocorrectionType = .no
        contentsTextView.autocorrectionType = .no
        categoryTextField.autocorrectionType = .no
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 画面遷移するとき
    override func viewWillDisappear(_ animated: Bool) {

        // レルムを更新
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }

        // 通知をセットする
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    // 通知をセットする
    func setNotification(task: Task) {

        let content = UNMutableNotificationContent()

        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }

        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }

        // 通知音の設定
        content.sound = UNNotificationSound.default

        // カレンダー生成
        let calendar = Calendar.current

        // 通知する日時を作成
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)

        // 通知トリガーを作成
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // 通知リクエストを作成（identifierが同じだと通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // 通知センターに通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
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
