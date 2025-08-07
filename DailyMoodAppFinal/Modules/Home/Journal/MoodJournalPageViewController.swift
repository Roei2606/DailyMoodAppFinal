import UIKit
import FirebaseFirestore
import FirebaseAuth

class MoodJournalPageViewController: UIViewController {
    
    private var pageViewController: UIPageViewController!
    private var dailyEntries: [(date: Date, entries: [JournalEntry])] = []
    private var sortedDates: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Journal"
        setupPageViewController()
        setupCalendarButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchJournalEntries()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }

    private func setupCalendarButton() {
        let calendarButton = UIButton(type: .system)
        calendarButton.setImage(UIImage(named: "icon_calendar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        calendarButton.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: calendarButton)
        navigationItem.rightBarButtonItem = barButton
    }

    @objc private func calendarTapped() {
        let calendar = Calendar.current
        let entryDatesSet: Set<Date> = Set(dailyEntries.map { calendar.startOfDay(for: $0.date) })
        
        let calendarVC = CalendarDialogViewController(entryDates: entryDatesSet) { [weak self] selectedDate in
            self?.openPageForDate(selectedDate)
        }
        present(calendarVC, animated: true)
    }

    private func openPageForDate(_ date: Date) {
        let calendar = Calendar.current
        guard let index = dailyEntries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }),
              let vc = viewControllerForIndex(index) else { return }

        pageViewController.setViewControllers([vc], direction: .forward, animated: true)
    }

    private func fetchJournalEntries() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("journalEntries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching journal entries: \(error)")
                    return
                }
                
                var groupedEntries: [Date: [JournalEntry]] = [:]
                let calendar = Calendar.current
                
                snapshot?.documents.forEach { document in
                    if let entry = try? document.data(as: JournalEntry.self) {
                        let day = calendar.startOfDay(for: entry.date)
                        groupedEntries[day, default: []].append(entry)
                    }
                }

                self.sortedDates = groupedEntries.keys.sorted()
                self.dailyEntries = self.sortedDates.map { ($0, groupedEntries[$0] ?? []) }
                
                let today = calendar.startOfDay(for: Date())
                if let todayIndex = self.sortedDates.firstIndex(of: today),
                   let todayVC = self.viewControllerForIndex(todayIndex) {
                    self.pageViewController.setViewControllers([todayVC], direction: .forward, animated: false)
                } else if let firstVC = self.viewControllerForIndex(0) {
                    self.pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
                }
            }
    }
    
    private func viewControllerForIndex(_ index: Int) -> UIViewController? {
        guard index >= 0 && index < dailyEntries.count else { return nil }
        let (date, entries) = dailyEntries[index]
        return JournalDayViewController(date: date, entries: entries, index: index)
    }
}

extension MoodJournalPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? JournalDayViewController else { return nil }
        return viewControllerForIndex(vc.index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? JournalDayViewController else { return nil }
        return viewControllerForIndex(vc.index + 1)
    }
}
