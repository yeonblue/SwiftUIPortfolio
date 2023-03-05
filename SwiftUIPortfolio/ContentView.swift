//
//  ContentView.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectdIssue) { // select가 nil일 수도 있으므로 optional이어야 함
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText,
                    tokens: $dataController.filterTokens,
                    suggestedTokens: .constant(dataController.suggestedFilterTokens),
                    prompt: "Fitler issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        
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
