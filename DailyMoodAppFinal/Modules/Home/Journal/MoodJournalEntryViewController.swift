import UIKit
import FirebaseFirestore
import FirebaseAuth

class MoodJournalEntryViewController: UIViewController {
    
    var selectedMood: String?
    private var questions: [String] = []
    private var answerFields: [UITextView] = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Today's Journal"
        
        setupNavigationBar()
        setupKeyboardObservers()
        setupDismissKeyboardGesture()
        setupQuestions()
        setupLayout()
    }
    
    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        backButton.setImage(
            UIImage(named: "icon_back")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backToMood), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc private func backToMood() {
        if let viewControllers = navigationController?.viewControllers {
            for controller in viewControllers {
                if controller is CurrentMoodViewController {
                    navigationController?.popToViewController(controller, animated: true)
                    return
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func setupQuestions() {
        switch selectedMood?.lowercased() {
        case "happy":
            questions = [
                "What made you feel happy today?",
                "Who or what contributed to this feeling?",
                "How can you repeat this tomorrow?"
            ]
        case "sad":
            questions = [
                "What made you feel sad today?",
                "How did you respond to the feeling?",
                "What could help you feel better?"
            ]
        case "angry":
            questions = [
                "What triggered your anger?",
                "How did you handle the situation?",
                "Would you do something differently next time?"
            ]
        case "tired":
            questions = [
                "Why did you feel tired today?",
                "Did you rest or take breaks?",
                "How can you improve your energy tomorrow?"
            ]
        case "calm":
            questions = [
                "What helped you feel calm today?",
                "How did it affect your day?",
                "Can you practice it again tomorrow?"
            ]
        case "stressed":
            questions = [
                "What caused your stress today?",
                "How did you cope with it?",
                "Is there anything you can change to reduce it?"
            ]
        default:
            questions = [
                "How did you feel today?",
                "What influenced your mood?",
                "How did you deal with it?"
            ]
        }
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        for question in questions {
            let label = UILabel()
            label.text = question
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.numberOfLines = 0
            
            let textView = UITextView()
            textView.layer.borderColor = UIColor.systemGray4.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8
            textView.font = UIFont.systemFont(ofSize: 15)
            textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            answerFields.append(textView)
            contentStack.addArrangedSubview(label)
            contentStack.addArrangedSubview(textView)
        }
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveEntry), for: .touchUpInside)
        contentStack.addArrangedSubview(saveButton)
    }

    @objc private func saveEntry() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user")
            return
        }

        var answersDict: [String: String] = [:]
        for (index, question) in questions.enumerated() {
            let answer = answerFields[index].text ?? ""
            if !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                answersDict[question] = answer
            }
        }

        guard !answersDict.isEmpty else {
            showAlert(title: "Missing answers", message: "Please fill in at least one answer.")
            return
        }

        let mood = selectedMood ?? "Unknown"
        let now = Date()

        let journalEntry = JournalEntry(
            id: nil,
            userId: uid,
            date: now,
            mood: mood,
            answers: answersDict
        )

        let userRef = Firestore.firestore().collection("users").document(uid)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        let dateKey = formatter.string(from: now)

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        let hour = hourFormatter.string(from: now)


        userRef.getDocument { snapshot, error in
            var updatedHistory = [String: String]()
            if let data = snapshot?.data(),
               let existingHistory = data["moodHistory"] as? [String: String] {
                updatedHistory = existingHistory
            }

            updatedHistory[dateKey] = mood

            userRef.updateData([
                "currentMood": mood,
                "lastActiveHour": hour,
                "moodHistory": updatedHistory
            ]) { error in
                if let error = error {
                    print("❌ Failed to update mood: \(error.localizedDescription)")
                } else {
                    print("✅ Mood '\(mood)' saved to user profile")
                }
            }
        }

       
        do {
            try Firestore.firestore().collection("journalEntries").addDocument(from: journalEntry)
            showAlert(title: "Saved!", message: "Your journal entry has been saved.") {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } catch {
            print("❌ Error saving journal entry: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Could not save your entry.")
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView.contentInset.bottom = keyboardFrame.height + 20
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }
}
