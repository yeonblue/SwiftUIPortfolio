//
//  IssueView.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/25.
//

import SwiftUI

struct IssueView: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                    
                    Picker("Priority", selection: $issue.priority) {
                        Text("Low").tag(Int16(0)) // xcDataModel에서 타입을 Integer16으로 했기 때문
                        Text("Medium").tag(Int16(1))
                        Text("High").tag(Int16(2))
                    }
                    
                    Menu {
                        ForEach(issue.issueTags) { tag in
                            Button {
                                issue.removeFromTags(tag)
                            } label: {
                                Label(tag.tagName, image: "checkmark")
                            }
                        }
                        
                        // show unselectd tags
                        let otherTags = dataController.missingTags(from: issue)
                        
                        if otherTags.isEmpty == false {
                            Divider()
                            
                            Section("Add Tags") {
                                ForEach(otherTags) { tag in
                                    Button(tag.tagName) {
                                        issue.addToTags(tag)
                                    }
                                }
                            }
                        }
                        
                    } label: {
                        Text(issue.issueTagsList)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.none, value: issue.issueTagsList)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description",
                              text: $issue.issueContent,
                              prompt: Text("Enter the issue description here"),
                              axis: .vertical) // 길이가 길어질 경우 아래로 확장이 됨
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            
            // onchange는 뷰 내부의 상태(예: @State 변수)가 변경될 때마다 실행되는 클로저입니다.
            // 이 클로저는 사용자 상호작용(예: 버튼 탭, 텍스트 필드 입력 등)에 응답하는 데 사용될 수 있습니다.
            
            // onreceive는 SwiftUI에서 상태 관리를 위해 ObservableObject를 사용할 때 유용합니다.
            // 이 클로저는 ObservableObject에서 @Published 프로퍼티의 값이 변경될 때마다 실행됩니다.
            // .onReceive(myObject.$count) { newValue in ..., myObject.objectWillChange()도 동일
            
            // 즉 onChange 클로저는 뷰 내부의 @State 변수나 @Binding, @Enviroment 변수 등의 상태가 변경될 때만 호출
            // 따라서 onChange(issue)는 동작하지 않음을 유의
            
            dataController.save()
        }
    }
}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        IssueView(issue: .example)
            .environmentObject(DataController.preview)
    }
}

/*
 SwiftUI에서는 Text View에서 일부 Markdown 구문을 사용하여 텍스트 서식을 지정할 수 있다. 예를 들어, **볼드체**는 굵은 텍스트로 표시됩니다.
 Text("이탤릭체는 *이탤릭체* 혹은 _이탤릭체_")
 Text("굵은 글씨는 **굵은 글씨** 혹은 __굵은 글씨__")
 */
