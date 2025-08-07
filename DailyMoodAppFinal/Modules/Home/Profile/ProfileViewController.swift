import UIKit
import DGCharts
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController {

    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    private let moodStreakLabel = UILabel()
    private let noDataLabel = UILabel()
    private let pieChartView = PieChartView()
    private let chartTitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupLogoutButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }

    private func setupUI() {
        profileImageView.image = UIImage(named: "profile_avatar")
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        [usernameLabel, emailLabel, moodStreakLabel, noDataLabel].forEach {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 16)
        }

        usernameLabel.textAlignment = .left
        emailLabel.textAlignment = .left
        moodStreakLabel.textAlignment = .center
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = .secondaryLabel
        noDataLabel.isHidden = true

        chartTitleLabel.text = "📊 Daily Mood Statistics"
        chartTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        chartTitleLabel.textAlignment = .center

        let infoStack = UIStackView(arrangedSubviews: [usernameLabel, emailLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.alignment = .leading

        let profileInfoStack = UIStackView(arrangedSubviews: [profileImageView, infoStack])
        profileInfoStack.axis = .horizontal
        profileInfoStack.spacing = 16
        profileInfoStack.alignment = .center
        profileInfoStack.translatesAutoresizingMaskIntoConstraints = false

        let chartContainer = UIView()
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.backgroundColor = .clear

        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(pieChartView)

        NSLayoutConstraint.activate([
            pieChartView.centerXAnchor.constraint(equalTo: chartContainer.centerXAnchor),
            pieChartView.topAnchor.constraint(equalTo: chartContainer.topAnchor),
            pieChartView.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor),
            pieChartView.widthAnchor.constraint(equalTo: chartContainer.widthAnchor),
            pieChartView.heightAnchor.constraint(equalToConstant: 280)
        ])

        // Chart title + chart stack
        let chartStack = UIStackView(arrangedSubviews: [chartTitleLabel, chartContainer])
        chartStack.axis = .vertical
        chartStack.spacing = 8
        chartStack.alignment = .center
        chartStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [
            profileInfoStack,
            moodStreakLabel,
            chartStack,
            noDataLabel
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            chartContainer.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ])
    }

    private func setupLogoutButton() {
        let logoutButton = UIButton(type: .system)
        logoutButton.setImage(UIImage(named: "logout_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        let label = UILabel()
        label.text = "Logout"
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .label

        let stack = UIStackView(arrangedSubviews: [logoutButton, label])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center

        let barButton = UIBarButtonItem(customView: stack)
        navigationItem.rightBarButtonItem = barButton
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            do {
                try FirebaseAuthManager.shared.signOut()
                self.navigateToLogin()
            } catch {
                print("❌ Failed to sign out: \(error.localizedDescription)")
            }
        })
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }

    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("❌ Failed to fetch user data:", error?.localizedDescription ?? "Unknown error")
                return
            }

            self.usernameLabel.text = "👤 Username: \(data["username"] as? String ?? "-")"
            self.emailLabel.text = "📧 Email: \(data["email"] as? String ?? "-")"

            if let urlString = data["profileImageUrl"] as? String,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_avatar"))
            }

            if let history = data["moodHistory"] as? [String: String], !history.isEmpty {
                self.moodStreakLabel.text = "🧘 Mood Streak: \(history.count) Daily reports"
                self.setupPieChart(from: history)
            } else {
                self.pieChartView.isHidden = true
                self.noDataLabel.isHidden = false
                self.noDataLabel.text = "Not enough data"
            }
        }
    }

    private func setupPieChart(from history: [String: String]) {
        let moodLabels: [String: String] = [
            "Angry": "😡",
            "Calm": "😌",
            "Stressed": "🤯",
            "Happy": "😊",
            "Sad": "😢",
            "Tired": "🥱"
        ]

        let moodColors: [String: UIColor] = [
            "Happy": .systemYellow,
            "Sad": .systemBlue,
            "Angry": .systemRed,
            "Calm": .systemTeal,
            "Stressed": .systemOrange,
            "Tired": .systemGray
        ]

        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)

        let filtered = history.filter { $0.key.starts(with: todayString) }

        var moodCount: [String: Double] = [:]
        for mood in filtered.values {
            moodCount[mood, default: 0] += 1
        }

        let entries = moodCount.compactMap { (mood, count) -> PieChartDataEntry? in
            guard let emoji = moodLabels[mood] else { return nil }
            return PieChartDataEntry(value: count, label: emoji)
        }

        guard entries.count > 0 else {
            pieChartView.isHidden = true
            noDataLabel.isHidden = false
            noDataLabel.text = "Not enough data for today"
            return
        }

        let dataSet = PieChartDataSet(entries: entries, label: "")

        dataSet.colors = entries.map { entry in
            let mood = moodLabels.first { $0.value == entry.label }?.key ?? ""
            return moodColors[mood] ?? .systemGray
        }

        dataSet.drawValuesEnabled = true
        dataSet.entryLabelColor = UIColor.label
        dataSet.valueFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dataSet.sliceSpace = 2
        
        pieChartView.holeColor = .clear
        pieChartView.legend.enabled = false
        pieChartView.data = PieChartData(dataSet: dataSet)
        pieChartView.centerText = "Mood History"
        pieChartView.animate(xAxisDuration: 1.2, easingOption: .easeOutBack)
        pieChartView.isHidden = false
        noDataLabel.isHidden = true
    }
}
