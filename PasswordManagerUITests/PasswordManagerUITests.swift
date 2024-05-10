//
//  PasswordManagerUITests.swift
//  PasswordManagerUITests
//
//  Created by Kento Akazawa on 4/15/24.
//

import XCTest

final class PasswordManagerUITests: XCTestCase {
  
  private var app: XCUIApplication!
  private let masterPw = "Master Password"
  private let wrongPw = "wrong password"
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    // UI tests must launch the application that they test.
    app = XCUIApplication()
    app.launch()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    app = nil
  }
  
  func testSetMasterPw() {
    let pwField = app.textFields["Password"]
    XCTAssertTrue(pwField.exists)
    pwField.tap()
    pwField.typeText(masterPw)
    
    let sendBtn = app.images["Send"]
    XCTAssertTrue(sendBtn.exists)
    sendBtn.tap()
    
    let navBar = app.navigationBars["Password List"]
    XCTAssertTrue(navBar.exists)
  }
  
  func testWrongMasterPw() {
    let pwField = app.textFields["Password"]
    XCTAssertTrue(pwField.exists)
    pwField.tap()
    pwField.typeText(wrongPw)
    
    let sendBtn = app.images["Send"]
    XCTAssertTrue(sendBtn.exists)
    sendBtn.tap()
    
    let navBar = app.navigationBars["Password List"]
    XCTAssertFalse(navBar.exists)
  }
  
  func testChangePw() {
    let changeLink = app.buttons["Change Password"]
    XCTAssertTrue(changeLink.exists)
    changeLink.tap()
    
    let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
    XCTAssertTrue(element.exists)
    let pwField = element.children(matching: .textField).element(boundBy: 0)
    XCTAssertTrue(pwField.exists)
    let newPwField = element.children(matching: .textField).element(boundBy: 1)
    XCTAssertTrue(newPwField.exists)
    pwField.tap()
    pwField.typeText(wrongPw)
    newPwField.tap()
    newPwField.typeText(masterPw)
    
    XCTAssertFalse(changeLink.exists)
    
    let delTextBtn = element.children(matching: .image).matching(identifier: "Close").element(boundBy: 0)
    XCTAssertTrue(delTextBtn.exists)
    delTextBtn.tap()
    pwField.tap()
    pwField.typeText(masterPw)
    
    let saveBtn = app.navigationBars["Change Password"].buttons["Save"]
    XCTAssertTrue(saveBtn.exists)
    saveBtn.tap()
    
    XCTAssertTrue(changeLink.exists)
  }
  
  func testAddPw() {
    let masterPW = masterPw
    let title = "ONU"
    let username = "onu@onu.edu"
    let password = "!6Yr4FjZ8?{1K4"
    
    let masterPwField = app.textFields["Password"]
    XCTAssertTrue(masterPwField.exists)
    masterPwField.tap()
    masterPwField.typeText(masterPW)
    
    let sendButton = app.images["Send"]
    XCTAssertTrue(sendButton.exists)
    sendButton.tap()
    
    let addButton = app.navigationBars["Password List"].buttons["Add"]
    XCTAssertTrue(addButton.exists)
    addButton.tap()
    
    let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
    let titleField = element.children(matching: .textField).element(boundBy: 0)
    let usernameField = element.children(matching: .textField).element(boundBy: 1)
    let pwField = element.children(matching: .textField).element(boundBy: 2)
    XCTAssertTrue(titleField.exists)
    XCTAssertTrue(usernameField.exists)
    XCTAssertTrue(pwField.exists)
    titleField.tap()
    titleField.typeText(title)
    usernameField.tap()
    usernameField.typeText(username)
    pwField.tap()
    pwField.typeText(password)
    
    let saveButton = app.navigationBars["Add Password"].buttons["Save"]
    XCTAssertTrue(saveButton.exists)
    saveButton.tap()
    
    let weakPwAlert = app.alerts["Are you sure?"].scrollViews.otherElements
    XCTAssertFalse(weakPwAlert.element.exists)
    
    let onuPwText = app.collectionViews.buttons["ONU, onu@onu.edu"]
    XCTAssertTrue(onuPwText.exists)
    onuPwText.tap()
    
    let pwHiddenText = app.staticTexts["●●●●●●●●●●●●●●"]
    XCTAssertTrue(pwHiddenText.exists)
    pwHiddenText.tap()
    
    let pwText = app.staticTexts[password]
    XCTAssertTrue(pwText.exists)
    
    let copyBtn = element.children(matching: .image).matching(identifier: "Document").element(boundBy: 1)
    XCTAssertTrue(copyBtn.exists)
    copyBtn.tap()
    
    let copyText = app.staticTexts["Text Copied"]
    XCTAssertTrue(copyText.exists)
    
    let expectation = XCTestExpectation(description: "Delay expectation")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // fulfill the expectation after the delay
      expectation.fulfill()
    }
    // wait for the expectation to be fulfilled for a maximum of 2 seconds
    wait(for: [expectation], timeout: 2)
    
    let delPwBtn = app.buttons["Delete Password"]
    XCTAssertTrue(delPwBtn.exists)
    delPwBtn.tap()
    
    let delBtn = app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Delete"]
    XCTAssertTrue(delBtn.exists)
    delBtn.tap()
  }
  
  func testWeakPw() {
    let masterPW = masterPw
    let title = "ONU"
    let username = "onu@onu.edu"
    let password = "password"
    let strongPw = "!6Yr4FjZ8?{1K4"
    
    let masterPwField = app.textFields["Password"]
    XCTAssertTrue(masterPwField.exists)
    masterPwField.tap()
    masterPwField.typeText(masterPW)
    
    let sendButton = app.images["Send"]
    XCTAssertTrue(sendButton.exists)
    sendButton.tap()
    
    let addButton = app.navigationBars["Password List"].buttons["Add"]
    XCTAssertTrue(addButton.exists)
    addButton.tap()
    
    let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
    let titleField = element.children(matching: .textField).element(boundBy: 0)
    let usernameField = element.children(matching: .textField).element(boundBy: 1)
    let pwField = element.children(matching: .textField).element(boundBy: 2)
    XCTAssertTrue(titleField.exists)
    XCTAssertTrue(usernameField.exists)
    XCTAssertTrue(pwField.exists)
    titleField.tap()
    titleField.typeText(title)
    usernameField.tap()
    usernameField.typeText(username)
    pwField.tap()
    pwField.typeText(password)
    
    let saveButton = app.navigationBars["Add Password"].buttons["Save"]
    XCTAssertTrue(saveButton.exists)
    saveButton.tap()
    
    let weakPwAlert = app.alerts["Are you sure?"].scrollViews.otherElements
    let alertSaveButton = weakPwAlert.buttons["Save"]
    XCTAssertTrue(weakPwAlert.element.exists)
    XCTAssertTrue(alertSaveButton.exists)
    
    alertSaveButton.tap()
    
    let onuPwText = app.collectionViews.buttons["\(title), \(username)"]
    XCTAssertTrue(onuPwText.exists)
    onuPwText.tap()
    
    let navBar = app.navigationBars[title]
    let editButton = navBar.buttons["Edit"]
    XCTAssertTrue(navBar.exists)
    XCTAssertTrue(editButton.exists)
    editButton.tap()
    
    let editElement = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
    XCTAssertTrue(editElement.exists)
    let editPwField = element.children(matching: .textField).element(boundBy: 2)
    XCTAssertTrue(editPwField.exists)
    let delTextBtn = element.children(matching: .image).matching(identifier: "Close").element(boundBy: 2)
    XCTAssertTrue(delTextBtn.exists)
    delTextBtn.tap()
    editPwField.tap()
    editPwField.typeText(strongPw)
    
    let editNavBar = app.navigationBars["Edit Password"]
    let saveBtn1 = editNavBar.buttons["Save"]
    XCTAssertTrue(editNavBar.exists)
    XCTAssertTrue(saveBtn1.exists)
    saveBtn1.tap()
    
    let backBtn = navBar.staticTexts["Back"]
    XCTAssertTrue(backBtn.exists)
    backBtn.tap()
    
    XCTAssertTrue(onuPwText.exists)
    onuPwText.tap()
    
    let delPwBtn = app.buttons["Delete Password"]
    XCTAssertTrue(delPwBtn.exists)
    delPwBtn.tap()
    
    let delBtn = app.alerts["Are you sure?"].scrollViews.otherElements.buttons["Delete"]
    XCTAssertTrue(delBtn.exists)
    delBtn.tap()
  }
  
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
