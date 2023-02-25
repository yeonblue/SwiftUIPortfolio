//
//  IssueRow.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/25.
//

import SwiftUI

struct IssueRow: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                
                // if issue.priority로 하면 priority가 2가 아니면 전체적으로 왼쪽으로 밀릴 수 있음
                
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        //.lineLimit(2...2) // 두줄이 되든 안되는 2줄을 채움, iOS 16이상 가능
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(issue.issueCreationDate.formatted(date: .numeric, time: .omitted))
                    
                    if issue.completed {
                        Text("Closed".uppercased())
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct IssueRow_Previews: PreviewProvider {
    static var previews: some View {
        IssueRow(issue: .example)
            .environmentObject(DataController.preview)
            .previewLayout(.sizeThatFits)
    }
}

/*
 SwiftUI에서 foregroundColor와 foregroundStyle은 모두 View에서 사용할 수 있는 속성이며,
 텍스트와 같은 View 내부의 콘텐츠의 색상을 정의하는 데 사용됩니다. 그러나 두 속성은 조금 다른 역할을 합니다.

 foregroundColor는 단순히 색상을 지정하는 데 사용됩니다.
 예를 들어, .foregroundColor(.red)를 사용하면 텍스트의 색상이 빨간색으로 설정됩니다.
 이와 같이 foregroundColor는 단일 색상만 지정할 수 있습니다.

 foregroundStyle은 다양한 속성을 결합하여 전체적인 스타일을 정의하는 데 사용됩니다.
 */
