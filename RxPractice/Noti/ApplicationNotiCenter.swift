//
//  ApplicationNotiCenter.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/27.
//

import RxSwift
import Foundation
enum ApplicationNotiCenter:NotificationCenterType{
    case downLoadingCount
    var name:Notification.Name{
        switch self{
        case .downLoadingCount:
            return Notification.Name("downLoadingCount")
        }
    }
}
protocol NotificationCenterType{
    var name:Notification.Name{ get }
}
extension ApplicationNotiCenter{
    func addObserver() -> Observable<Any?>{
        return NotificationCenter.default.rx.notification(self.name).map{$0.object}
    }
    func post(object:Any? = nil){
        NotificationCenter.default.post(name: self.name, object: object,userInfo: nil)
    }
}
