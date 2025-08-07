import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

class CurrentMoodViewController: UIViewController {

    let moods: [(name: String, image: String, tip: String)] = [
        ("Happy", "mood_happy", "Keep smiling and spread your joy! 😄"),
        ("Calm", "mood_calm", "Take a deep breath and enjoy the peace 🧘‍♂️"),
        ("Tired", "mood_tired", "Rest your body and mind. 💤"),
        ("Angry", "mood_angry", "Count to 10... then smile 🙂"),
        ("Sad", "mood_sad", "It's okay to feel sad. Treat yourself kindly 💙"),
        ("Stressed", "mood_stress", "Step back and take a few deep breaths 🫁")
    ]

    var selectedMoodIndex: Int? = nil
    var moodViews: [UIView] = []
    var audioPlayer: AVAudioPlayer?
    let db = Firestore.firestore()
    let dailyTipLabel = UILabel()
    let journalButton = UIButton()

    private var lastMoodSelectionTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Mood"

        setupMoodGrid()
        setupDailyTipLabel()
        setupJournalButton()
        loadSound()
    }

    func setupMoodGrid() {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 30
        verticalStack.alignment = .center
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        for rowIndex in 0..<2 {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.spacing = 20
            horizontalStack.distribution = .fillEqually
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false

            for columnIndex in 0..<3 {
                let index = rowIndex * 3 + columnIndex
                if index < moods.count {
                    let moodView = createMoodView(index: index)
                    horizontalStack.addArrangedSubview(moodView)
                    moodViews.append(moodView)
                }
            }
            verticalStack.addArrangedSubview(horizontalStack)
        }
    }

    func createMoodView(index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: moods[index].image))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let label = UILabel()
        label.text = moods[index].name
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        container.layer.cornerRadius = 12
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.clear.cgColor
        container.backgroundColor = .clear
        container.tag = index

        let tap = UITapGestureRecognizer(target: self, action: #selector(moodTapped(_:)))
        container.addGestureRecognizer(tap)

        return container
    }

    func setupDailyTipLabel() {
        dailyTipLabel.font = .systemFont(ofSize: 16)
        dailyTipLabel.textColor = .secondaryLabel
        dailyTipLabel.textAlignment = .center
        dailyTipLabel.numberOfLines = 0
        dailyTipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dailyTipLabel)

        NSLayoutConstraint.activate([
            dailyTipLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            dailyTipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dailyTipLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupJournalButton() {
        journalButton.setTitle("Write about it", for: .normal)
        journalButton.setTitleColor(.white, for: .normal)
        journalButton.backgroundColor = .black
        journalButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        journalButton.layer.cornerRadius = 8
        journalButton.setImage(UIImage(named: "icon_pencil"), for: .normal)
        journalButton.tintColor = .white
        journalButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)

        journalButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(journalButton)

        NSLayoutConstraint.activate([
            journalButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            journalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            journalButton.heightAnchor.constraint(equalToConstant: 50),
            journalButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 240)
        ])

        journalButton.addTarget(self, action: #selector(openJournal), for: .touchUpInside)
    }

    @objc func openJournal() {
        guard let index = selectedMoodIndex else {
            showAlert(title: "Mood required", message: "Please select your mood before writing.")
            return
        }

        let vc = MoodJournalEntryViewController()
        vc.selectedMood = moods[index].name
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }

        if let lastTime = lastMoodSelectionTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < 60 {
                let remaining = Int(ceil(60 - elapsed))
                showAlert(title: "Please wait", message: "You can choose a new mood in \(remaining) seconds.")
                return
            }
        }

        selectedMoodIndex = tappedView.tag
        lastMoodSelectionTime = Date()

        for (i, view) in moodViews.enumerated() {
            view.layer.borderColor = (i == selectedMoodIndex) ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }

        let tip = moods[selectedMoodIndex!].tip
        dailyTipLabel.text = "💡 Tip: \(tip)"
        playSound()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func loadSound() {
        guard let soundURL = Bundle.main.url(forResource: "mood_click", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Could not load sound file.")
        }
    }

    func playSound() {
        audioPlayer?.play()
    }
}
