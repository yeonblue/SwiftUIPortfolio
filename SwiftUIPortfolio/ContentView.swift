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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                        dataController.filterEnabled.toggle()
                    }
                    
                    Divider()
                    
                    Menu("Sort By") {
                        Picker("Sort By", selection: $dataController.sortType) {
                            Text("Date Created").tag(SortType.dateCreated)
                            Text("Date Modified").tag(SortType.dateModified)
                        }
                        
                        Divider()
                        
                        Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                            Text("Newest to Oldest").tag(true)
                            Text("Oldest to Newest").tag(false)
                        }
                    }
                    
                    Picker("Status", selection: $dataController.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Open").tag(Status.open)
                        Text("Closed").tag(Status.closed)
                    }
                    .disabled(dataController.filterEnabled == false)
                    
                    Picker("Priority", selection: $dataController.filterPriority) {
                        Text("All").tag(-1)
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .disabled(dataController.filterEnabled == false)
                    
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolVariant(dataController.filterEnabled ? .fill : .none)
                }
            }
        }
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
        NavigationStack {
            ContentView()
                .environmentObject(DataController.preview)
        }
    }
}
