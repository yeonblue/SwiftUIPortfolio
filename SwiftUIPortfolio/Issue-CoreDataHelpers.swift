//
//  Issue-CoreDataHelpers.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/17.
//

import Foundation

/*
 CoreData는 Property가 Optional로 되어 있기에 매 번 nil-collapse로 접근하는 것은 불편하므로 extension을 정의
 xcDataModel에서 CodeGen을 none으로 하고 Optional이 아니게 정의할 수도 있지만, 기본적으로 Optional로 프로퍼티는 생성되므로
 확장성을 생각하면 이는 적합하지 않음.
 Setter, Getter를 정의하여 nil-collapse를 사용하지 않고 읽고, 쓰기 가능
*/

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var issueContent: String {
        get { content ?? ""}
        set { content = newValue }
    }
    
    var issueCreationDate: Date {
        creationDate ?? Date.now
    }
    
    var issueModificationDate: Date {
        modificationDate ?? Date.now
    }
    
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var issueTagsList: String {
        guard let tags else { return "No Tags"}
        
        if tags.count == 0 {
            return "No Tags"
        } else {
            return issueTags.map(\.tagName).formatted() // 배열을 합쳐서 ,와 한칸씩 띄워서 반환
        }
    }
    
    var issueStatus: String {
        if completed {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = Date.now
        return issue
    }
}

extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase
        
        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
