//
//  PasswordManager.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI
import CryptoKit
import CoreData

struct Password {
  var title: String
  var username: String
  var password: String
  var note: String
  var website: String
}

class PasswordManager {
  // singleton instance of this class
  static let shared = PasswordManager()

  // keys for UserDefaults
  // used to get data from UserDefaults
  private let masterPwKey = "Master Password"
  private let symmetricKey = "Symmetric Key"
  private let saltKey = "Salt"
  // symmetric key used for encryption
  private var key = SymmetricKey(size: .bits256)
  private let saltLength = 16
  private let minPwLength = 12
  private let strongPwLength = 14

  // MARK: - Initialization

  init() {
    // if the symmetric key has already been generated, assign it to @key
    // otherwise, create new key and save it to UserDefaults
    if let keyData = UserDefaults.standard.data(forKey: symmetricKey) {
      key = SymmetricKey(data: keyData)
    } else {
      // new symmetric key is created when object of this class is created
      // convert symmetric key to Data and store in UserDefaults
      let keyData = key.withUnsafeBytes { Data($0) }
      UserDefaults.standard.set(keyData, forKey: symmetricKey)
    }
  }


  // MARK: - Public Functions

  // set the master password
  func setMasterPassword(_ pw: String) {
    // generate salt and save to UserDefault
    let salt = getSalt()
    UserDefaults.standard.set(salt, forKey: saltKey)
    // add salt, hash and save to UserDefault
    UserDefaults.standard.set(hashPassword(pw, salt: salt), forKey: masterPwKey)
  }

  // checks if master password has already been set
  func doesMasterPasswordExist() -> Bool {
    // master password is saved in UserDefaults
    return UserDefaults.standard.data(forKey: masterPwKey) != nil
  }

  // checks if master password saved in UserDefaults matches @pw
  func doesMasterPasswordMatch(_ pw: String) -> Bool {
    // get master password from UserDefault
    guard let masterPw = UserDefaults.standard.data(forKey: masterPwKey) else { 
      return false
    }
    // get salt from UserDefault
    guard let salt = UserDefaults.standard.data(forKey: saltKey) else {
      return false
    }
    // since master password is saved after being hashed
    // compare @pw after adding same salt and hashing
    return hashPassword(pw, salt: salt) == masterPw
  }

  // add @pw to the database after encrypting its password
  func addPassword(_ pw: Password, context: NSManagedObjectContext) {
    // encrypt password
    guard let password = encrypt(pw.password) else { return }
    // save to database
    DataController().addPassword(title: pw.title,
                                 username: pw.username,
                                 password: password,
                                 note: pw.note,
                                 website: pw.website,
                                 context: context)
  }

  // edit @pw in the database after encrypting its password
  func editPassword(_ pw: Password, to passwords: Passwords, context: NSManagedObjectContext) {
    // encrypt password
    guard let password = encrypt(pw.password) else { return }
    // save to database
    DataController().editPassword(passwords,
                                  title: pw.title,
                                  username: pw.username,
                                  password: password,
                                  note: pw.note,
                                  website: pw.website,
                                  context: context)
  }

  // decrypts @encryptedData and return the original password as string
  func getPassword(_ encryptedData: Data) -> String {
    return decryptPassword(encryptedData) ?? ""
  }

  // generates password with @length
  func generatePassword() -> String {
    let letters = ["abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "1234567890", "!@#$%^&*()-_=+[]{}|;:,.<>?/~"]
    // list of index where each type of letters (lowercase, uppercase, number, special char) are stored
    // this ensures that there is at least one character of each type
    let randomIndexes = Array(Array(0..<strongPwLength).shuffled().prefix(4))
    var pw = Array<Character>(repeating: " ", count: strongPwLength)

    // assign each type of character to random index
    for i in 0..<letters.count {
      let tmp = letters[i]
      let randomIndex = Int.random(in: 0..<tmp.count)
      let randomCharacter = tmp[tmp.index(tmp.startIndex, offsetBy: randomIndex)]
      pw[randomIndexes[i]] = randomCharacter
    }

    // randomly pick character from letters
    for i in 0..<strongPwLength {
      // if certain character is already determined from last loop
      // don't change that character
      if !randomIndexes.contains(i) {
        // random index to determine which type of letters
        var randomIndex = Int.random(in: 0..<letters.count)
        let tmp = letters[randomIndex]
        // random index to determine which character with in the lettters
        randomIndex = Int.random(in: 0..<tmp.count)
        let randomCharacter = tmp[tmp.index(tmp.startIndex, offsetBy: randomIndex)]
        pw[i] = randomCharacter
      }
    }
    return String(pw)
  }

  // calculates the strength of @pw
  func getPasswordStrength(_ pw: String) -> Int {
    var strength = 0

    // check length
    let length = pw.count
    if length >= minPwLength {
      strength += 1
    }
    // check for uppercase letters
    let uppercaseRegex = ".*[A-Z]+.*"
    if NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: pw) {
      strength += 1
    }
    // check for lowercase letters
    let lowercaseRegex = ".*[a-z]+.*"
    if NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: pw) {
      strength += 1
    }
    // check for digits
    let digitRegex = ".*[0-9]+.*"
    if NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: pw) {
      strength += 1
    }
    // check for special characters
    let specialCharacterRegex = ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]+.*"
    if NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: pw) {
      strength += 1
    }
    return strength
  }

  // MARK: - Private Functions

  // hash @pw using SHA-256
  private func hashPassword(_ pw: String, salt: Data) -> Data {
    // convert string to data
    guard let pwData = pw.data(using: .utf8) else {
      fatalError("Failed to convert password to data")
    }
    // add salt
    let data = pwData + salt
    // hash the password using SHA-256
    return Data(SHA256.hash(data: data))
  }

  // encrypts @pw and return encrypted password as Data
  private func encrypt(_ pw: String) -> Data? {
    // convert string to data before encryption
    guard let pwData = pw.data(using: .utf8) else {
      return nil
    }
    // add salt
    let data = pwData + getSalt()
    do {
      let sealedBox = try AES.GCM.seal(data, using: key)
      return sealedBox.combined
    } catch {
      print("Encryption failed: \(error.localizedDescription)")
      return nil
    }
  }

  // decrypts @encryptedData and return password as string
  private func decryptPassword(_ encryptedData: Data) -> String? {
    do {
      // decrypts using AES-GCM algorithm
      let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
      let decryptedData = try AES.GCM.open(sealedBox, using: key)
      // extract salt from decrypted data
      let pwData = decryptedData.dropLast(saltLength)
      // converts data to string using UTF8
      return String(data: pwData, encoding: .utf8)
    } catch {
      print("Decryption failed: \(error.localizedDescription)")
      return nil
    }
  }

  // generates random data with @saltLength as bite size
  private func getSalt() -> Data {
    let salt = Data(count: saltLength)
    var mutableSalt = salt
    _ = mutableSalt.withUnsafeMutableBytes { mutableBytes in
      SecRandomCopyBytes(kSecRandomDefault, saltLength, mutableBytes.baseAddress!)
    }
    return mutableSalt
  }
}
