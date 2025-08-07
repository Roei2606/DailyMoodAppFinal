import UIKit
import Lottie
import FirebaseAuth

class SplashViewController: UIViewController {

    private let animationView = LottieAnimationView(name: "lottie_open_screen")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAnimation()
    }

    private func setupAnimation() {
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        view.addSubview(animationView)

        animationView.play { [weak self] _ in
            self?.goToLogin()
        }
    }

    private func goToLogin() {
        if let user = Auth.auth().currentUser {
            print("✅ User is already logged in: \(user.email ?? "")")
            goToHome()
        } else {
            print("👤 No user logged in – going to login screen")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            }
        }
    }

    private func goToHome() {
        let homeVC = HomeViewController()
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true)
    }

}
