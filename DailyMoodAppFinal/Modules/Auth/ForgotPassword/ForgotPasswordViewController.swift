import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_back"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset your password"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        return tf
    }()

    private let resetPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Reset Email", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Forgot Password"

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(resetPasswordButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            resetPasswordButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            resetPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            resetPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // הקשה על הרקע תסגור מקלדת
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapReset() {
        guard let rawEmail = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawEmail.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }

        let email = rawEmail.lowercased()

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(message: "Error: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Email Sent", message: "If an account exists for this email, a reset link has been sent.")
            }
        }
    }

    private func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
