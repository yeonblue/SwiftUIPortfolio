//
//  ContentView.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        
        if let tag = filter.tag {
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            
            // tag가 없다면(Smart Filters를 통해 왔다면?)
            let request = Issue.fetchRequest()
            
            // CoreData는 Swift Type은 지원안하고 Objective-C Type만을 지원하기 때문에 NSDate사용
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificatonData as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    
    var body: some View {
        List(selection: $dataController.selectdIssue) { // select가 nil일 수도 있으므로 optional이어야 함
            ForEach(issues) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataController.preview)
    }
}
