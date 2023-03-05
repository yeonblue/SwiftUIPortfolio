//
//  DataController.swift
//  SwiftUIPortfolio
//
//  Created by yeonBlue on 2023/02/14.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    @Published var selectedFilter: Filter? = .all
    @Published var selectdIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    /// 3초마다 CoreData 저장작업을 수행
    private var saveTask: Task<Void, Error>?
    
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }
        
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    let container: NSPersistentCloudKitContainer // NSPersistContainer와 달리 CloudKit과도 sync가 가능
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        // Preview용, 실제로 저장하지 않음
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        // 멀티쓰레드 환경, 다중 기기 환경에서 CoreData의 데이터 일관성을 유지하기 위해 설정
        // 이 두 줄의 코드는 부모 컨텍스트와 동기화하고, 병합 정책을 설정함으로써 viewContext가 다른 컨텍스트와 일관성 있게 동작할 수 있도록 보장.
        // 아래 주석 참고
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        // 원격 저장소 변경 사항에 대한 Notification 수신 설정
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator,
                                               queue: .main,
                                               using: remoteStoreChanged)
        
        // CoreData에 저장된 목록을 불러옴
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    /// remote 저장소와 sink를 맞추기 위한 함수
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description \(j)"
                issue.creationDate = Date.now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue) // coredata relationship으로 추가되었기에 자동으로 제공하는 함수
            }
        }
        
        try? viewContext.save()
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    // https://developer.apple.com/documentation/coredata/nsbatchdeleterequest
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs // 삭제된 object ID를 얻음
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
    }
    
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        
        // Set 구조체에서 symmetricDifference(_:) 메서드를 호출하면, 해당 집합과 전달된 집합 사이의 대칭 차집합을 반환합니다.
        // 예를 들어, let setA: Set = [1, 2, 3]와 let setB: Set = [3, 4, 5] 라는 두 집합이 있을 때,
        // setA.symmetricDifference(setB)는 [1, 2, 4, 5] 라는 결과를 반환합니다.
        
        let difference = allTagsSet.symmetricDifference(issue.issueTags) // issueTags와 allTagsSet의 대칭 차집합을 구함
        
        return difference.sorted()
    }
    
    func issuesForSelectedFilter() -> [Issue] {
        
        // NSPredicate와 달리 NSCompoundPredicate는 여러 Predicate를 활용 가능, and. .or, .not 가능
        // let predicate1 = NSPredicate(format: "name == %@ OR name == %@", "John", "Mary")
        // let predicate2 = NSPredicate(format: "age >= %@ AND age <= %@", 20, 30)
        // let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])

        // 아래는 모든 subPredicates를 and로 결합
        // let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            
            // CoreData는 Swift Type은 지원안하고 Objective-C Type만을 지원하기 때문에 NSDate사용
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificatonData as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if trimmedFilterText.isEmpty == false {
            
            // [c]는 대소문자 구분을 하지 않는 옵션. 즉, title 속성에는 대소문자를 구분하지 않고 trimmedFilterText 문자열이 포함되어 있는지를 검사
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        // 중복된 태그가 모두 있는지 체크
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues.sorted()
    }
    
    func queueSave() {
        saveTask?.cancel()
        
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
}

/*
 1.
 container.viewContext.automaticallyMergesChangesFromParent = true
 Core Data에서는 기본적으로 작업하는 context와 그 context의 parent context, 즉 상위 context 간에 변경사항을 서로 복제하거나 merge하는 과정이 필요합니다.

 container.viewContext.automaticallyMergesChangesFromParent = true는 viewContext가 해당 context의 parent context로부터 변경 사항을 자동으로 merge하도록 설정
 이 설정을 활성화하면, parent context에서 변경이 발생하면 자동으로 viewContext에 적용되어 뷰에 반영됩니다.

 예를 들어, viewContext가 메인 스레드에서 작동하는 경우, 백그라운드 스레드에서 작동하는 background context에서 변경이 발생하면,
 viewContext가 해당 변경사항을 복제하고, 그 결과 뷰에 반영됩니다.

 하지만 이 설정이 활성화되어 있어도, 동일한 객체를 동시에 여러 개의 context에서 변경하면 충돌이 발생할 수 있습니다.
 이런 경우에는 NSMergePolicy를 사용하여 충돌 상황을 처리할 수 있습니다.
 
 2.
 NSMergePolicy
 Core Data는 다중 스레드 환경에서 데이터 변경 작업을 수행할 때 일관성을 유지하기 위한 다양한 정책을 제공합니다. 그 중 하나가 NSMergePolicy입니다.

 NSMergePolicy는 변경 작업 중 발생하는 충돌을 해결하는 데 사용되는 정책입니다.
 변경 작업이 발생하는 경우, Core Data는 관련된 모든 객체를 변경 관리 컨텍스트에서 가져와서 업데이트합니다.
 그러나 다른 컨텍스트에서 이미 해당 객체를 변경했을 수 있습니다. 이 경우 충돌이 발생하고 NSMergePolicy가 충돌을 해결하는 방법을 결정합니다.
 
 mergeByPropertyStoreTrump는 데이터 저장소의 값이 우선됩니다. (local이 우선, remote는 나중)
 즉, 저장소의 값을 유지하고 다른 컨텍스트의 변경 사항은 무시됩니다. 이 정책은 서로 동일한 객체를 수정하는 두 개의 컨텍스트에서 사용될 때 유용합니다.
 이 경우에는 마지막으로 변경된 속성이 다른 속성을 덮어씁니다.
 이 정책은 데이터의 일관성을 유지하는 데 유용합니다.
 */
