import Foundation
import FirebaseFirestore


struct JournalEntry: Codable {
    @DocumentID var id: String?         // מזהה ייחודי לרשומה
    let userId: String                  // מזהה המשתמש
    let date: Date                      // תאריך הרישום
    let mood: String                    // מצב הרוח הנבחר
    let answers: [String: String]       // שאלות ותשובות מהיומן
}
