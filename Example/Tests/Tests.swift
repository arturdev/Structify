import XCTest
import Structify
import RealmSwift

class Tests: XCTestCase {
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Structify.go()
    }
        
    func test_1_StructToClass() {
        
        var location = Location()
        location.lat = 2
        location.lng = 3
        
        var user = User()
        user.id = "goa938jaoj3a9jagjfa3f"
        user.firstname = "John"
        user.birthday = dateFormatter.date(from: "14.05.1993")!
        user.isAdmin = true
        user.location = location
        
        var post = Post()
        post.id = "393010jf1093j019jgf1"
        post.title = "Owesome post!"
        post.owner = user
        
        let rlmPost = post.toObject()
        print(rlmPost)
        let realm = try! Realm()
        try! realm.write {
            realm.add(rlmPost)
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_2_ClassToStruct() {
        let realm = try! Realm()
        let rlmPost = realm.objects(RLMPost.self).last!
        
        print(rlmPost)
        
        let post = rlmPost.toStruct()
        print(post)
        
        XCTAssertEqual(post.id, "393010jf1093j019jgf1")
        XCTAssertEqual(post.title, "Owesome post!")
        XCTAssertEqual(post.owner.id, "goa938jaoj3a9jagjfa3f")
        XCTAssertEqual(post.owner.firstname, "John")
        XCTAssertEqual(post.owner.location.lat, 2)
        XCTAssertEqual(post.owner.location.lng, 3)
        XCTAssertEqual(post.owner.isAdmin, true)
        
        XCTAssert(true, "Pass")
    }
}
