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
