import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthManager {

    static let shared = FirebaseAuthManager()
    private init() {}
    private let db = Firestore.firestore()

    // MARK: - הרשמה
    func register(email: String, password: String, username: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                let uid = user.uid

                let userData: [String: Any] = [
                    "uid": uid,
                    "email": email,
                    "username": username,
                    "currentMood": "",
                    "moodHistory": [:],
                    "activeHours": "",
                    "profileImageUrl": ""
                ]

                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let userModel = UserModel(
                            uid: uid,
                            email: email,
                            username: username,
                            profileImageUrl: "",
                            moodHistory: [:]
                        )
                        completion(.success(userModel))
                    }
                }
            }
        }
    }

    // MARK: - התחברות
    func login(email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.fetchUserData(uid: user.uid, completion: completion)
            }
        }
    }

    // MARK: - שליפת פרטי משתמש
    func fetchUserData(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "No user data", code: -1)))
                return
            }

            let userModel = UserModel(
                uid: uid,
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String ?? "",
                moodHistory: data["moodHistory"] as? [String: String] ?? [:],
            )
            completion(.success(userModel))
        }
    }

    // MARK: - יציאה
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
