//
//  SwiftUIPortfolioApp.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import SwiftUI

@main
struct SwiftUIPortfolioApp: App {
    
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SideBarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}

// 앱이 한번 생성되고, 매번 새로고침되는 것을 원할 경우(변경되는 것을 관찰하고 싶지 않음) @State를 사용
// State의 경우 안에서 @Publish 프로퍼티가 변경되어도, dataController 자체에 값이 새로 할당되지 않는 한, view를 새로 그리지 않음.
// StateObject의 경우 objectWillChange 이벤트가 발생할 때 마다, view가 새로 그려짐
