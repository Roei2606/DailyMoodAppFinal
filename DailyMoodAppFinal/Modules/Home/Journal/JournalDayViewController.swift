import UIKit

class JournalDayViewController: UIViewController {

    private let date: Date
    private let entries: [JournalEntry]
    let index: Int

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let dateLabel = UILabel()
    private let stackView = UIStackView()

    init(date: Date, entries: [JournalEntry], index: Int) {
        self.date = date
        self.entries = entries
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        configureWithData()
    }

    private func setupLayout() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Date Label
        dateLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Stack View
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func configureWithData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_US")
        dateLabel.text = formatter.string(from: date)

        for entry in entries {
            let stickyNote = createStickyNote(for: entry)
            stackView.addArrangedSubview(stickyNote)
        }
    }

    private func createStickyNote(for entry: JournalEntry) -> UIView {
    
        let backgroundImage = UIImage(named: "note_bg")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
    
        let contentStack = UIStackView()
            contentStack.axis = .vertical
            contentStack.alignment = .center
            contentStack.spacing = 8
            contentStack.translatesAutoresizingMaskIntoConstraints = false

            // Mood
            let emoji = emojiForMood(entry.mood)
            let moodLabel = UILabel()
            moodLabel.text = "\(emoji) \(entry.mood)"
            moodLabel.font = UIFont.boldSystemFont(ofSize: 18)
            moodLabel.textColor = .black
            moodLabel.textAlignment = .center
            moodLabel.numberOfLines = 0
            contentStack.addArrangedSubview(moodLabel)

            // Q&A
            for (question, answer) in entry.answers {
                let questionLabel = UILabel()
                questionLabel.text = question
                questionLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                questionLabel.textColor = .black
                questionLabel.textAlignment = .center
                questionLabel.numberOfLines = 0

                let answerLabel = UILabel()
                answerLabel.text = answer
                answerLabel.font = UIFont.systemFont(ofSize: 10)
                answerLabel.textColor = .darkGray
                answerLabel.textAlignment = .center
                answerLabel.numberOfLines = 0

                contentStack.addArrangedSubview(questionLabel)
                contentStack.addArrangedSubview(answerLabel)
            }


        imageView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            contentStack.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 50),
            contentStack.widthAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor, constant: -32)
        ])

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        let screenWidth = UIScreen.main.bounds.width
        let desiredWidth = screenWidth - 40 

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            imageView.widthAnchor.constraint(equalToConstant: desiredWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.05)
        ])

        return container
    }


    private func emojiForMood(_ mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "😄"
        case "calm": return "🧘‍♂️"
        case "tired": return "😴"
        case "angry": return "😠"
        case "sad": return "😢"
        case "stressed": return "😰"
        default: return "📝"
        }
    }
}
