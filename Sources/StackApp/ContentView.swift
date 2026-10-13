import SwiftUI
import AppKit

// MARK: - App Delegate
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Stack App"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Onboarding
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    let pages: [(icon: String, title: String, body: String)] = [
        ("square.stack.3d.up.fill", "Welcome to Stack App",
         "A simple way to organize items as stacks — just like the data structure: Last In, First Out."),
        ("hand.draw.fill", "Create, Push, Pop",
         "Create named stacks, push items on top, and pop them off. Search, edit, and reorder your stacks freely."),
        ("sparkles", "Why use it?",
         "Perfect for todos, reading lists, undo histories, and anything that benefits from a clear \"top of mind\".")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: pages[page].icon)
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text(pages[page].title)
                .font(.largeTitle).bold()

            Text(pages[page].body)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
                .frame(maxWidth: 500)

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Circle()
                        .fill(i == page ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            HStack {
                if page > 0 {
                    Button("Back") { page -= 1 }
                        .buttonStyle(.bordered)
                } else {
                    Button("Skip") {
                        finish()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if page < pages.count - 1 {
                    Button("Next") { page += 1 }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") { finish() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(width: 600, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }

    func finish() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isPresented = false
    }
}

// MARK: - Help View
struct HelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Help & About")
                    .font(.title2).bold()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    section(
                        icon: "questionmark.circle.fill",
                        title: "Why?",
                        body: """
                        A stack is one of the simplest and most powerful data structures — \
                        Last In, First Out. It mirrors how we naturally work: \
                        the newest item is the most relevant.

                        This app makes that mental model visual and persistent. \
                        Instead of scattered notes, you keep a clean pile per topic — \
                        todos, reading list, undo history, ideas — and always know what's on top.
                        """
                    )

                    section(
                        icon: "book.fill",
                        title: "How to use",
                        body: """
                        1. Create a stack — give it a name and optional notes (sidebar form).

                        2. Push — type a value and press Push or Enter. It lands on top.

                        3. Pop — removes the top item. LIFO order is preserved.

                        4. Edit — click ✏️ Edit in the header, or right-click a stack → Rename / Edit.

                        5. Search — filter by name or notes. Counter updates live.

                        6. Reorder — drag stacks in the sidebar to change the order.

                        7. Dark mode — pick System / Light / Dark from the toolbar (persists).

                        Keyboard: ⌘F focuses search · ⌘? opens this help.
                        """
                    )

                    section(
                        icon: "star.fill",
                        title: "Benefits",
                        body: """
                        • Clear focus — the top item is always what matters most.

                        • Perfect structure — undo stacks, breadcrumbs, navigation history, \
                        expression evaluation, DFS — stacks are everywhere.

                        • Lightweight — no accounts, no cloud, no clutter.

                        • Persistent across launches — stacks, notes, and preferences are saved.

                        • Fully native — SwiftUI on macOS, fast and accessible.
                        """
                    )
                }
                .padding(24)
            }
        }
        .frame(width: 620, height: 620)
    }

    func section(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.tint)
                Text(title).font(.headline)
            }
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Main View
struct ContentView: View {
    // Persistence
    @AppStorage("themeMode") private var themeModeRaw: String = ThemeMode.system.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var themeMode: Binding<ThemeMode> {
        Binding(
            get: { ThemeMode(rawValue: themeModeRaw) ?? .system },
            set: { themeModeRaw = $0.rawValue }
        )
    }

    // State
    @State private var stacks: [NamedStack] = [
        NamedStack(name: "My First Stack", notes: "Demo stack"),
        NamedStack(name: "Todo", notes: "Things to do"),
        NamedStack(name: "Reading List", notes: "Books to read")
    ]
    @State private var selectedStackID: UUID?

    @State private var searchText = ""
    @State private var newStackName = ""
    @State private var newStackNotes = ""
    @State private var pushValue = ""

    @State private var isEditing = false
    @State private var editName = ""
    @State private var editNotes = ""

    @State private var showHelp = false
    @State private var showOnboarding = false

    var filteredStacks: [NamedStack] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty { return stacks }
        let q = searchText.lowercased()
        return stacks.filter {
            $0.name.lowercased().contains(q) || $0.notes.lowercased().contains(q)
        }
    }

    var selectedStack: NamedStack? {
        stacks.first { $0.id == selectedStackID }
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let stack = selectedStack {
                detailView(for: stack)
            } else {
                Text("Select or create a stack")
                    .foregroundStyle(.secondary)
            }
        }
        .preferredColorScheme(themeMode.wrappedValue.colorScheme)
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Picker("Theme", selection: themeMode) {
                        ForEach(ThemeMode.allCases) { m in
                            Label(m.label, systemImage: m.icon).tag(m)
                        }
                    }
                    .pickerStyle(.inline)
                } label: {
                    Image(systemName: themeMode.wrappedValue.icon)
                }
                .help("Theme: \(themeMode.wrappedValue.label)")

                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .keyboardShortcut("/", modifiers: [.command, .shift])
                .help("Help (⌘⇧/)")
            }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onAppear {
            selectedStackID = stacks.first?.id
            if !hasSeenOnboarding {
                showOnboarding = true
            }
        }
    }

    // MARK: - Sidebar
    var sidebar: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search stacks…", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.12)))
            .padding(.horizontal)

            Text("Stacks (\(filteredStacks.count))")
                .font(.headline)
                .padding(.horizontal)

            List(selection: $selectedStackID) {
                ForEach(filteredStacks) { stack in
                    VStack(alignment: .leading) {
                        Text(stack.name)
                        Text("\(stack.count) items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(stack.id)
                    .contextMenu {
                        Button("Rename / Edit") {
                            selectedStackID = stack.id
                            startEditing(stack)
                        }
                        Button("Delete", role: .destructive) {
                            deleteStack(stack)
                        }
                    }
                }
                .onMove { indices, newOffset in
                    guard searchText.isEmpty else { return }
                    stacks.move(fromOffsets: indices, toOffset: newOffset)
                }
                .onDelete { indexSet in
                    guard searchText.isEmpty else { return }
                    let ids = indexSet.map { filteredStacks[$0].id }
                    stacks.removeAll { ids.contains($0.id) }
                    if !stacks.contains(where: { $0.id == selectedStackID }) {
                        selectedStackID = stacks.first?.id
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("New Stack").font(.subheadline).bold()
                TextField("Name", text: $newStackName)
                    .textFieldStyle(.roundedBorder)
                TextField("Notes", text: $newStackNotes)
                    .textFieldStyle(.roundedBorder)
                Button("Add Stack") {
                    let s = NamedStack(
                        name: newStackName.isEmpty ? "Untitled" : newStackName,
                        notes: newStackNotes
                    )
                    stacks.append(s)
                    selectedStackID = s.id
                    newStackName = ""
                    newStackNotes = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(minWidth: 280)
    }

    // MARK: - Detail
    @ViewBuilder
    func detailView(for stack: NamedStack) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            if isEditing {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Stack name", text: $editName)
                        .font(.title2).bold()
                        .textFieldStyle(.roundedBorder)
                    TextField("Notes", text: $editNotes)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Button("Save") { saveEdit(stack) }
                            .buttonStyle(.borderedProminent)
                        Button("Cancel") { isEditing = false }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(stack.name).font(.largeTitle).bold()
                        Spacer()
                        Button {
                            startEditing(stack)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .buttonStyle(.bordered)
                    }
                    Text("Notes: \(stack.notes.isEmpty ? "—" : stack.notes)")
                        .foregroundStyle(.secondary)
                    Text("Top: \(stack.top?.value ?? "empty")").font(.callout)
                    Text("Size: \(stack.count)").font(.callout)
                }
                .padding(.horizontal)
            }

            Divider()

            HStack {
                TextField("Value to push", text: $pushValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 250)
                    .onSubmit { push(stack) }
                Button("Push") { push(stack) }
                    .buttonStyle(.borderedProminent)
                Button("Pop") { pop(stack) }
                    .buttonStyle(.bordered)
                    .disabled(stack.items.isEmpty)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 4) {
                    if stack.items.isEmpty {
                        Text("Stack is empty")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(stack.items.reversed())) { item in
                            HStack {
                                Text("▲").foregroundStyle(.orange)
                                Text(item.value)
                                Spacer()
                                Text(String(item.id.uuidString.prefix(6)))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.blue.opacity(item.id == stack.top?.id ? 0.25 : 0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue.opacity(0.4))
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.vertical)
    }

    // MARK: - Actions
    func startEditing(_ stack: NamedStack) {
        editName = stack.name
        editNotes = stack.notes
        isEditing = true
    }

    func saveEdit(_ stack: NamedStack) {
        guard let i = stacks.firstIndex(where: { $0.id == stack.id }) else { return }
        stacks[i].name = editName.isEmpty ? "Untitled" : editName
        stacks[i].notes = editNotes
        isEditing = false
    }

    func deleteStack(_ stack: NamedStack) {
        stacks.removeAll { $0.id == stack.id }
        if selectedStackID == stack.id {
            selectedStackID = stacks.first?.id
            isEditing = false
        }
    }

    func push(_ stack: NamedStack) {
        guard !pushValue.isEmpty else { return }
        if let i = stacks.firstIndex(where: { $0.id == stack.id }) {
            stacks[i].items.append(StackItem(value: pushValue))
        }
        pushValue = ""
    }

    func pop(_ stack: NamedStack) {
        if let i = stacks.firstIndex(where: { $0.id == stack.id }),
           !stacks[i].items.isEmpty {
            stacks[i].items.removeLast()
        }
    }
}
