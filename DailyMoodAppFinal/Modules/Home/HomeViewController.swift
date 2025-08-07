import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(named: "tab_profile")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_profile")?.withRenderingMode(.alwaysOriginal)
        )
        
        let moodVC = CurrentMoodViewController()
        moodVC.tabBarItem = UITabBarItem(
            title: "Mood",
            image: UIImage(named: "tab_mood")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_mood")?.withRenderingMode(.alwaysOriginal)
        )
        
        let journalVC = MoodJournalPageViewController()
        journalVC.tabBarItem = UITabBarItem(
            title: "Journal",
            image: UIImage(named: "tab_diary")?.withRenderingMode(.alwaysOriginal), 
            selectedImage: UIImage(named: "tab_diary")?.withRenderingMode(.alwaysOriginal)
        )
        
        viewControllers = [
            UINavigationController(rootViewController: profileVC),
            UINavigationController(rootViewController: moodVC),
            UINavigationController(rootViewController: journalVC)
        ]
        
        tabBar.tintColor = .label
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.backgroundColor = .systemBackground
    }
}
