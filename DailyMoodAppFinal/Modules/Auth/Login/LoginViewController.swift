import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
    }

    // MARK: - Styling
    private func styleUI() {
        registerButton.layer.cornerRadius = 10
        registerButton.layer.masksToBounds = true
        registerButton.setTitleColor(.white, for: .normal)

        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.setTitleColor(.white, for: .normal)
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Firebase login error: \(error.localizedDescription)")
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }

            // ✅ התחברות הצליחה
            print("✅ Logged in as \(authResult?.user.email ?? "unknown user")")
            self.goToHomeScreen()
        }
    }

    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        print("🔑 Forgot Password tapped")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let forgotVC = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController {
            forgotVC.modalPresentationStyle = .fullScreen
            self.present(forgotVC, animated: true, completion: nil)
        } else {
            print("❌ Couldn't find ForgotPasswordViewController in storyboard")
        }
    }


    @IBAction func registerButtonTapped(_ sender: UIButton) {
        print("✅ Register button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            registerVC.modalPresentationStyle = .fullScreen
            self.present(registerVC, animated: true, completion: nil)
        } else {
            print("❌ Couldn't find RegisterViewController in storyboard")
        }
    }

    // MARK: - Navigation
    private func goToHomeScreen() {
        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }


    // MARK: - Helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
