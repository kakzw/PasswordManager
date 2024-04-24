//
//  PasswordManagerTests.swift
//  PasswordManagerTests
//
//  Created by Kento Akazawa on 4/15/24.
//

import XCTest
@testable import PasswordManager

final class PasswordManagerTests: XCTestCase {
  
  private var model: PasswordManager!
  
  override func setUpWithError() throws {
    model = PasswordManager()
  }
  
  override func tearDownWithError() throws {
    model = nil
  }
  
  // MARK: - Encryption & Decryption
  
  func testSuccessfulEncryption() {
    // Given (Arrange)
    let pw = ""
    
    // When(Act)
    guard let encrypted = model.encryptTest(pw) else {
      return
    }
    guard let decrypted = model.decryptTest(encrypted) else {
      return
    }
    
    // Then (Assert)
    XCTAssertEqual(pw, decrypted)
  }
  
  func testEmptyStringEncryption() {
    let pw = ""
    
    guard let encrypted = model.encryptTest(pw) else {
      return
    }
    guard let decrypted = model.decryptTest(encrypted) else {
      return
    }
    
    XCTAssertEqual(pw, decrypted)
  }
  
  func testEmojiEncryption() {
    let pw = "😊"
    
    guard let encrypted = model.encryptTest(pw) else {
      return
    }
    guard let decrypted = model.decryptTest(encrypted) else {
      return
    }
    
    XCTAssertEqual(pw, decrypted)
  }
  
  // MARK: - Hash
  
  func testSuccessfulHash() {
    let pw = "!6Yr4FjZ8?{1K4"
    let salt = model.saltTest()
    
    let hashed1 = model.hashTest(pw, salt: salt)
    let hashed2 = model.hashTest(pw, salt: salt)
    
    XCTAssertEqual(hashed1, hashed2)
  }
  
  func testDifferentPwHash() {
    let pw1 = "!6Yr4FjZ8?{1K4"
    let pw2 = "!6Yr4FjZ8?{1K3"
    let salt = model.saltTest()
    
    let hashed1 = model.hashTest(pw1, salt: salt)
    let hashed2 = model.hashTest(pw2, salt: salt)
    
    XCTAssertNotEqual(hashed1, hashed2)
  }
  
  func testDifferentSaltHash() {
    let pw = "!6Yr4FjZ8?{1K4"
    let salt1 = model.saltTest()
    let salt2 = model.saltTest()
    
    let hashed1 = model.hashTest(pw, salt: salt1)
    let hashed2 = model.hashTest(pw, salt: salt2)
    
    XCTAssertNotEqual(hashed1, hashed2)
  }
  
  func testEmptyPwHash() {
    let pw = ""
    let salt = model.saltTest()
    
    let hashed1 = model.hashTest(pw, salt: salt)
    let hashed2 = model.hashTest(pw, salt: salt)
    
    XCTAssertEqual(hashed1, hashed2)
  }
  
  func testEmojiHash() { 
    let pw = "😊"
    let salt = model.saltTest()
    
    let hashed1 = model.hashTest(pw, salt: salt)
    let hashed2 = model.hashTest(pw, salt: salt)
    
    XCTAssertEqual(hashed1, hashed2)
  }
  
  // MARK: - Password Strength
  
  func testSuccessfulPwStrength() {
    let pw = "!6Yr4FjZ8?{1K4"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 5)
  }
  
  func testNoLowercasePwStrength() {
    let pw = "!6YR4FJZ8?{1K4"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 4)
  }
  
  func testNoUppercasePwStrength() {
    let pw = "!6yr4fjz8?{1k4"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 4)
  }
  
  func testNoDigitPwStrength() {
    let pw = "!aYrfFjZe?{oKF"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 4)
  }
  
  func testNoSpecialPwStrength() {
    let pw = "e6Yr4FjZ8qb1K4"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 4)
  }
  
  func testShortPwStrength() {
    let pw = "!6Yr4FjZ8?{"
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 4)
  }
  
  func testEmptyPwStrength() {
    let pw = ""
    
    let res = model.getPasswordStrength(pw)
    
    XCTAssertEqual(res, 0)
  }
  
  // MARK: - Generate Strong Password
  
  func testGeneratePw() {
    let res = model.generatePassword()
    let pwStrength = model.getPasswordStrength(res)
    
    XCTAssertEqual(pwStrength, 5)
  }
}
