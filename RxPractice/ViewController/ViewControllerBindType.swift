//
//  ViewControllerBindType.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/25.
//

import Foundation
import UIKit

// 뷰와 뷰모델을 바인딩하는 프로토콜 정의
protocol ViewControllerBindType {
    associatedtype viewModelType
    var viewModel:viewModelType!{get set}
    func bindViewModel()
}
// UIViewController 타입일 때 bind()를 통하여 뷰모델을 바인딩 할 수 있음
extension ViewControllerBindType where Self:UIViewController{
    mutating func bind(viewModel:Self.viewModelType){
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
