import UIKit
import TOCropViewController
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginLabel: UIButton!
    @IBOutlet weak var stackViewAlreadyAcount: UIStackView!

    private var selectedProfileImage: UIImage?
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
        setupLoginTapGesture()
        setupProfileImageTap()
        setupKeyboardDismissTapGesture()
    }

    // MARK: - UI Setup
    private func styleUI() {
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        signUpButton.setTitleColor(.white, for: .normal)

        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

       
        loginLabel.setTitleColor(.label, for: .normal)
        loginLabel.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }


    private func setupProfileImageTap() {
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        profileImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Image Selection and Cropping
    @objc private func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                let cropVC = TOCropViewController(croppingStyle: .circular, image: image)
                cropVC.delegate = self
                self.present(cropVC, animated: true)
            }
        }
    }

    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        selectedProfileImage = image
        profileImageView.image = image
    }

    // MARK: - Sign Up
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match.")
            return
        }

        showLoading(true)

        FirebaseAuthManager.shared.register(email: email, password: password, username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("👤 Registered: \(user.email)")
                    self.uploadProfileImageIfNeeded(userId: user.uid)
                case .failure(let error):
                    self.showLoading(false)
                    print("❌ Registration error: \(error.localizedDescription)")
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func uploadProfileImageIfNeeded(userId: String) {
        guard let image = selectedProfileImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.showLoading(false)
            self.goToHomeScreen()
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("❌ Error uploading profile image: \(error.localizedDescription)")
                } else {
                    print("✅ putData succeeded, metadata: \(String(describing: metadata))")
                }
                self.showLoading(false)
                self.goToHomeScreen()
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    self.showLoading(false)
                    self.goToHomeScreen()
                    return
                }

                let imageUrl = url?.absoluteString ?? ""
                print("✅ Image uploaded. URL: \(imageUrl)")
                self.saveUserToFirestore(userId: userId, profileImageUrl: imageUrl)
            }
        }
    }

    private func saveUserToFirestore(userId: String, profileImageUrl: String?) {
        guard let email = emailTextField.text,
              let username = usernameTextField.text else {
            self.showLoading(false)
            self.goToHomeScreen()
            return
        }

        let userData: [String: Any] = [
            "uid": userId,
            "email": email,
            "username": username,
            "profileImageUrl": profileImageUrl ?? "",
            "moodHistory": [:]
        ]

        Firestore.firestore().collection("users").document(userId).setData(userData) { error in
            self.showLoading(false)
            if let error = error {
                print("❌ Firestore save error: \(error.localizedDescription)")
            } else {
                print("✅ User saved to Firestore")
            }
            self.goToHomeScreen()
        }
    }

    // MARK: - Spinner
    private func showLoading(_ show: Bool) {
        if show {
            if activityIndicator == nil {
                let spinner = UIActivityIndicatorView(style: .large)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.color = .gray
                view.addSubview(spinner)
                NSLayoutConstraint.activate([
                    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
                activityIndicator = spinner
            }
            activityIndicator?.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator?.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    // MARK: - Navigation
    private func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true, completion: nil)
    }

    // MARK: - Gesture Recognizer
    private func setupLoginTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loginLabelTapped))
        loginLabel.isUserInteractionEnabled = true
        loginLabel.addGestureRecognizer(tapGesture)
    }

    @IBAction func loginLabelTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }


    private func setupKeyboardDismissTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
