# Structify

[![Version](https://img.shields.io/cocoapods/v/Structify.svg?style=flat)](https://cocoapods.org/pods/Structify)
[![License](https://img.shields.io/cocoapods/l/Structify.svg?style=flat)](https://cocoapods.org/pods/Structify)
[![Platform](https://img.shields.io/cocoapods/p/Structify.svg?style=flat)](https://cocoapods.org/pods/Structify)

Structify is designed to make your life much easier especially when you want to deal with Swift structs rather than Objective-C classes and you have to manually convert your structs to classes and vice-a-versa to acheive that.<br>
The most obvious example is `Realm`.<br>

For example, assume you have a struct named `User` and you want to save it to `Realm`'s db.<br>
As you already know `Realm` doesn't support Swift structs, so the most common solution is making a pair class (which will have the same properties) and manually writing convertion methods.

#### Without Structify
```Swift
struct User {
    let address: String
    let company: String
    let email: String
    let name: String
    let phone: String
    let uid: String
    let username: String
    let website: String
    let birthday: Date
}

class RLMUser: Object {

    @objc dynamic var address: String = ""
    @objc dynamic var company: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var uid: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var website: String = ""
    @objc dynamic var birthday: Date = Date()
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RLMUser {
    func toStruct() -> User {
        return User(address: address,
                    company: company,
                    email: email,
                    name: name,
                    phone: phone,
                    uid: uid,
                    username: username,
                    website: website,
                    birthday: birthday)
    }
}

extension User {
    func toObject() -> RLMUser {
        return RLMUser.build { object in
            object.uid = uid
            object.address = address
            object.company = company
            object.email = email
            object.name = name
            object.phone = phone
            object.username = username
            object.website = website
            object.birthday = birthday
        }
    }
}
```

At a first glance it seems very convenient method. But what if your struct isn't so small and have much more properties? What if you have too many structs like `User`? What if you want to add more properties to existing structs during the development? You will have to write that boilerplate code for each of your structs! And if you forget also to add those additional properties into the Realm's pair-class you'll get bugs as a bonus!<br>
Agree, pretty annoying. <b>So here Structify comes to rescue!</b>

Long story short:
#### With Structify
```Swift
struct User {
    var address: String = ""
    var company: String = ""
    var email: String = ""
    var name: String = ""
    var phone: String = ""
    var uid: String = ""
    var username: String = ""
    var website: String = ""
    var birthday: Date = Date()
}

class RLMUser: Object {
    //you only set the primaryKey as usual 
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension RLMUser: StructConvertible {
    typealias StructType = User
}

extension User: ObjectConvertible {
    typealias ClassType = RLMUser
}
```
Pretty easy, huh? <br>
The only thing you need to do is make your struct to conform to `ObjectConvertible` protocol and make a Objective-C pair class and conform to `StructConvertible` protocol. You're done! 


## Example

```Swift
let user = User(address: "Some address",
                company: "Some company",
                email: "structify@example.com",
                name: "John",
                phone: "Doe",
                uid: "90jq0j30n0nc02930293",
                username: "arturdev",
                website: "http://github.com",
                birthday: Date())
        
let rlmUser = user.toObject()
print(rlmUser)
/*
Console:

RLMUser {
	address = Some address;
	company = Some company;
	email = structify@example.com;
	name = John;
	phone = Doe;
	uid = 90jq0j30n0nc02930293;
	username = arturdev;
	website = http://github.com;
	birthday = 2019-02-08 14:00:41 +0000;
}
*/

```

To see the example project, clone the repo, and run `pod install` from the Example directory first, then open Tests.swift

## Requirements

- iOS  8.0+
- Xcode 10.+
- Swift 4.2+

## Installation

Structify is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Structify'
```

## Author

arturdev, mkrtarturdev@gmail.com

## License

Structify is available under the MIT license. See the <a href = "https://github.com/arturdev/Structify/blob/master/LICENSE">LICENSE</a> file for more info.
