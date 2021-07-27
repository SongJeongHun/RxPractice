//
//  Transition.swift
//  RxPractice
//
//  Created by 송정훈 on 2021/07/24.
//

import Foundation

// 트랜지션 타입 분류
enum Transition{
    case modal
    case root
    case push
}
enum TransitionError:Error{
    case cannotPop
    case naviMissing
    case unknown
}
