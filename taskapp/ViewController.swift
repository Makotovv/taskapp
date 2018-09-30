//
//  ViewController.swift
//  taskapp
//
//  Created by Makoto Kaneko on 2018/09/20.
//  Copyright © 2018年 Makoto Kaneko. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンスを取得する
    //    let realm = try! Realm()
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付近い順ー順でソート：
    //以降内容をアップデートするとリスト内は自動的に更新される。
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //データの数（=セルの数）を返すメソッド
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return taskArray.count
        //        return 0
        
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for :indexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //MARk: UITableViewDelegateのプロトコルのメソッド
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }
    //セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView:UITableView, editingStyleForRowAt indexPath:IndexPath)-> UITableViewCellEditingStyle{
        return . delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //            try! realm.write{
            //                self.realm.delete(self.taskArray[indexPath.row])
            //                tableView.deleteRows(at:[indexPath],with: .fade)
            //        }
            
            // 削除されたタスクを取得
            let task = self.taskArray[indexPath.row]
            
            //            // データベースから削除する
            //            try! realm.write {
            //                self.realm.delete(task)
            //                tableView.deleteRows(at: [indexPath], with: .fade)
//        }
        
        // ローカル通知をキャンセルする
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
        
        //            let center = UNUserNotificationCenter.current()
        //            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
        // データベースから削除
        try! realm.write {
            self.realm.delete(task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        // 未通知のローカル通知一覧ログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
        }
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
           }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}


