import XCTest
import Structify
import RealmSwift
import Realm

class Tests: XCTestCase {
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()
    
    func configRealm() {
        let config = Realm.Configuration(
            schemaVersion: 18,
            migrationBlock: nil)
        
        let folderPath = Realm.Configuration.defaultConfiguration.fileURL!.deletingLastPathComponent().path
        print(folderPath)
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        configRealm()
        Structify.go()
    }
    
    func test_1_StructToClass() {
        var location = Location()
        location.lat = 2
        location.lng = 3
        
        var user = User()
        user.id = "goa938jaoj3a9jagjfa3f"
        user.firstname = "John"
        user.salary = 45.8
        user.birthday = dateFormatter.date(from: "14.05.1993")!
        user.isAdmin = true
        user.location = location
        user.someArray = ["1", "2", "3", "asd"]
        
        var post = Post()
        post.id = "393010jf1093j019jgf1"
        post.title = "Owesome post!"
        post.owner = user
        post.likes = [user, user, user]
        
        let rlmPost = post.toObject()
        print(rlmPost)
        let realm = try! Realm()
        try! realm.write {
            realm.add(rlmPost, update: true)
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_2_ClassToStruct() {
        let realm = try! Realm()
        let rlmPost = realm.objects(RLMPost.self).last!
        let post = rlmPost.toStruct()
        print(post)
        
        XCTAssertEqual(post.id, "393010jf1093j019jgf1")
        XCTAssertEqual(post.title, "Owesome post!")
        XCTAssertEqual(post.owner.id, "goa938jaoj3a9jagjfa3f")
        XCTAssertEqual(post.owner.firstname, "John")
        XCTAssertEqual(post.owner.salary, 45.8)
        XCTAssertEqual(post.owner.birthday, dateFormatter.date(from: "14.05.1993")!)
        XCTAssertEqual(post.owner.location.lat, 2)
        XCTAssertEqual(post.owner.location.lng, 3)
        XCTAssertEqual(post.owner.isAdmin, true)
        XCTAssertEqual(post.owner.someArray, ["1", "2", "3", "asd"])
        XCTAssertEqual(post.likes[0].id, post.owner.id)
        XCTAssertEqual(post.likes[1].id, post.owner.id)
        XCTAssertEqual(post.likes[2].id, post.owner.id)
        XCTAssert(true, "Pass")
    }
}
