//
//  ViewController.swift
//  taskapp
//
//  Created by HY on 2020/12/08.
//  Copyright © 2020 HY. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 検索バー
    @IBOutlet weak var searchBar: UISearchBar!

    // レルムのインスタンス
    let realm = try! Realm()
    
    // レルムの全データを日付の昇順で取得
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)

    // レルムのデータを日付の昇順で取得
//    var searchedTaskArray = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // テーブルを本クラスへ移譲
        tableView.delegate = self
        // データソースを本クラスへ移譲
        tableView.dataSource = self
        // 検索バーを本クラスへ移譲
        searchBar.delegate = self

        // 検索バー入力時に1文字目が大文字に変換されないようにする
        searchBar.autocapitalizationType = .none
        // 検索バー入力時の自動補正を無効にする
        searchBar.autocorrectionType = .no
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // 検索キーワードが空のとき
        if searchText.isEmpty {
            // レルムの全データを日付の昇順で取得
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        // 検索キーワードが入っているとき
        }else{
            // レルムのデータを検索キーワードで絞り込みして日付の昇順で取得
            taskArray = try! Realm().objects(Task.self).filter("category = '\(searchText)'").sorted(byKeyPath: "date", ascending: true)
        }

        // テーブル再表示
        tableView.reloadData()
    }
    
    // rowの数は？
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // rowのデータは？
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // データ１行分を取得
        let task = taskArray[indexPath.row]

        // タイトルをセルへ
        cell.textLabel?.text = task.title

        // 日付のフォーマットをセット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // 日付をセルへ
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }

    // セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セグエのIDを指定して画面遷移
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    // セルの編集可能パターンを返す
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }

    // 削除ボタンが押されたとき
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 編集パターンが削除可能なら
        if editingStyle == .delete {
            // 削除するデータを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                // テーブルビューからも削除
                tableView.deleteRows(at: [indexPath], with: .fade)
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

    }

    // 画面遷移の準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){

        // 次画面のインスタンス取得
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        // セルが押された場合
        if segue.identifier == "cellSegue" {
            
            // 選択行を取得
            let indexPath = self.tableView.indexPathForSelectedRow
            
            // 次画面に選択行のデータを渡す
            inputViewController.task = taskArray[indexPath!.row]
        
        // ＋が押された場合
        } else {
            
            // タスク新規登録用インスタンス生成
            let task = Task()

            // レルムの全データを取得
            let allTasks = realm.objects(Task.self)

            // データが存在する場合
            if allTasks.count != 0 {
                // 最後のID＋１を新規登録用IDとする
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            // 次画面に新規登録用のインスタンスを渡す
            inputViewController.task = task
        }
        
    }

    // 次画面から戻ってきた時
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // テーブルビューを更新する
        tableView.reloadData()
    }
    
}

