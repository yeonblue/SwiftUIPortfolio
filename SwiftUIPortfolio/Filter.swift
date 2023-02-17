//
//  Filter.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import Foundation

struct Filter: Identifiable, Hashable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var minModificatonData = Date.distantPast // 특정한 날짜를 비교하거나 사용하기 위한 값이 아닌 아주 오래전을 추상적으로 고려해야 할 때 사용
    var tag: Tag?
    
    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    
    /// 최근 7일
    static var recent = Filter(id: UUID(),
                               name: "Recent Issues",
                               icon: "clock",
                               minModificatonData: .now.addingTimeInterval(86400 * -7))
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
