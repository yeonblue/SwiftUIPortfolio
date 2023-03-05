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
    
    /// 앱이 현재 활성화되어 있는 상태를 나타내는 열거형, iOS 14 도입 (active, inactive, background)
    /// 현재 어떤 상태인지 알 수 있으므로, 이를 활용하여 앱의 동작을 제어할 수 있다.
    /// 예를 들어, 앱이 백그라운드 상태인 경우에는 특정 작업을 일시 중지하거나 저장을 하고, 앱이 다시 활성화된 경우에는 작업을 다시 시작하는 등의 처리를 할 수 있다.
    @Environment(\.scenePhase) var scenePhase
    
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
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}

// 앱이 한번 생성되고, 매번 새로고침되는 것을 원할 경우(변경되는 것을 관찰하고 싶지 않음) @State를 사용
// State의 경우 안에서 @Publish 프로퍼티가 변경되어도, dataController 자체에 값이 새로 할당되지 않는 한, view를 새로 그리지 않음.
// StateObject의 경우 objectWillChange 이벤트가 발생할 때 마다, view가 새로 그려짐
