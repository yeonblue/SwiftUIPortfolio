//
//  NoIssueView.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/25.
//

import SwiftUI

struct NoIssueView: View {
    var body: some View {
        
        // 상단 parent에서 containerView에서 사용 될 것
        
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            
            // make a new issue
        }
    }
}

struct NoIssueView_Previews: PreviewProvider {
    static var previews: some View {
        NoIssueView()
    }
}
