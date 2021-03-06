//
//  InputViewController.swift
//  taskapp
//
//  Created by Makoto Kaneko on 2018/09/22.
//  Copyright © 2018年 Makoto Kaneko. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datepicker: UIDatePicker!
    //textfieldをoutlet接続
    @IBOutlet weak var categoryTextField: UITextField!

    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datepicker.date = task.date
        //テキストフィルドとファイルを括り付ける
        categoryTextField.text =  task.category
        // Do any additional setup after loading the view.

        //枠のカラー(lowtextfield)
        categoryTextField.layer.borderColor = UIColor.black.cgColor
        // 枠の幅(lowtextfield)
        categoryTextField.layer.borderWidth = 1.0
        // 枠を角丸にする場合(lowtextfield)
        categoryTextField.layer.cornerRadius = 10.0
        categoryTextField.layer.masksToBounds = true
        
        //枠のカラー(textfield)
        titleTextField.layer.borderColor = UIColor.black.cgColor
        // 枠の幅(textfield)
        titleTextField.layer.borderWidth = 1.0
        // 枠を角丸にする場合(textView)
        titleTextField.layer.cornerRadius = 10.0
        titleTextField.layer.masksToBounds = true
        
        // 枠のカラー(textView)
        contentsTextView.layer.borderColor = UIColor.black.cgColor
        // 枠の幅(textView)
        contentsTextView.layer.borderWidth = 1.0
        // 枠を角丸にする場合(textView)
        contentsTextView.layer.cornerRadius = 10.0
        contentsTextView.layer.masksToBounds = true
        
        //枠のカラー(DatePicker)
        datepicker.layer.borderColor = UIColor.black.cgColor
        // 枠の幅(DatePicker)
        datepicker.layer.borderWidth = 1.0
        // 枠を角丸にする場合(DatePicker)
        datepicker.layer.cornerRadius = 10.0
        datepicker.layer.masksToBounds = true
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datepicker.date
            self.realm.add(self.task, update: true)
            self.task.category = self.categoryTextField.text!
        }
        
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task){
        let content  = UNMutableNotificationContent()
        if task.title ==  ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
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
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


