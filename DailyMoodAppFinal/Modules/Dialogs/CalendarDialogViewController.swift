import UIKit

class CalendarDialogViewController: UIViewController {

    private let entryDates: Set<Date>
    private let onDateSelected: (Date) -> Void
    private var selectedDate: Date = Date()
    
    private let calendar = Calendar.current
    private let datePicker = UIDatePicker()
    private let openButton = UIButton(type: .system)
    
    init(entryDates: Set<Date>, onDateSelected: @escaping (Date) -> Void) {
        self.entryDates = entryDates
        self.onDateSelected = onDateSelected
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    private func setupLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "📅 Select a Day"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // UIDatePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        openButton.setTitle("Open This Day ✅", for: .normal)
        openButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        openButton.isEnabled = false
        openButton.alpha = 0.5
        openButton.addTarget(self, action: #selector(openTapped), for: .touchUpInside)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(openButton)
        NSLayoutConstraint.activate([
            openButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        updateButtonState(for: datePicker.date)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        updateButtonState(for: sender.date)
    }
    
    private func updateButtonState(for date: Date) {
        let day = calendar.startOfDay(for: date)
        selectedDate = day
        
        if entryDates.contains(day) {
            openButton.isEnabled = true
            openButton.alpha = 1.0
        } else {
            openButton.isEnabled = false
            openButton.alpha = 0.5
        }
    }
    
    @objc private func openTapped() {
        dismiss(animated: true) {
            self.onDateSelected(self.selectedDate)
        }
    }
}
