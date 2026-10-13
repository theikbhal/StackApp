import Foundation

struct StackItem: Identifiable, Hashable {
    let id = UUID()
    let value: String
}

struct NamedStack: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var notes: String
    var items: [StackItem] = []

    var count: Int { items.count }
    var top: StackItem? { items.last }
}
