//
//  SceneCoordinatorType.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation
import RxSwift

// Coordinator 의 화면 트랜지션 및 종료 프로토콜 정의
protocol SceneCoordinatorType {
    func transition(to scene:Scene,using transition:Transition,animated:Bool) -> Completable
    func close(animated:Bool) -> Completable
}
