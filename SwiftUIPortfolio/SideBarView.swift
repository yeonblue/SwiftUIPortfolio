//
//  SideBarView.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import SwiftUI
import CoreData

struct SideBarView: View {
    
    @EnvironmentObject var dataController: DataController
    let smartFilter: [Filter] = [.all, .recent]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        
        // selectedFilter가 변경됨에 따라 ContentView의 표시되는 데이터도 바뀜
        // NavigtationLink의 필터 value가 @EnviromentObject로 선언된 DataController의
        // selectedFitler를 변경시키기에 가능함
        
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilter) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.tag?.tagActiveIssue.count ?? 0)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("Add Samples", systemImage: "flame")
            }
        }
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SideBarView()
                .environmentObject(DataController.preview)
        }
    }
}
