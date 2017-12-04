//
//  GameViewController.swift
//  Tamagotchi
//
//  Created by James Hughes on 07/11/2017.
//  Copyright © 2017 Tammo Team. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var gameManager = GameManager()
    
    @IBOutlet weak var hoursTitle: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var thermometer: UIImageView!
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var IceCreamOne: UIImageView!
    @IBOutlet weak var IceCreamTwo: UIImageView!
    @IBOutlet weak var IceCreamThree: UIImageView!
    @IBOutlet weak var touchHatVisual: UIButton!
    @IBOutlet weak var poopVisual: UIButton!
    @IBOutlet weak var feedVisual: UIButton!
    @IBOutlet weak var thoughtBubbleText: UILabel!
    @IBOutlet weak var thoughtBubble: UIImageView!
    @IBOutlet weak var happiness: UILabel!
    @IBOutlet weak var happinessTitle: UILabel!
    
    let constantTimeInterval = 12.0
    
    @IBOutlet weak var resetVisual: UIButton!
    
    var age = 0
    var hour = 0
    var hungryDays = 0
    var playDays = 0
    var happyDays = 0
    var ageActivated = true
    var ageTracker = Timer()
    var hourTracker = Timer()
    var x = Timer()
    var scene = GameplayScene(fileNamed: "GameplayScene")
    
    func creatureInteractionButtonsHidden(bool: Bool){
        self.poopVisual.isHidden = bool
        self.feedVisual.isHidden = bool
        self.thoughtBubble.isHidden = bool
        self.thoughtBubbleText.isHidden = bool
        self.resetVisual.isHidden = bool;
    }
    
    
    @IBAction func resetGame(_ sender: Any) {
        super.viewDidLoad()
        
        age = 0
        hungryDays = 0
        happyDays = 0
        
        ageLabel.text = String(age)
        creatureInteractionButtonsHidden(bool: true)
        self.happinessTitle.isHidden = true;
        self.happiness.isHidden = true;
        self.thermometer.isHidden = false;
        self.touchHatVisual.isHidden = false;
        self.tempLabel.isHidden = false;
        
        foodUIHide(bool: true)
        updateTempLabel()
        ageTracker = Timer()
        ageTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval, target: self, selector: (#selector(updateAge)), userInfo: nil, repeats: true)
        ageTracker = Timer()
        hourTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval/24, target: self, selector: (#selector(updateHour)), userInfo: nil, repeats: true)
        gameManager = GameManager()
        scene = GameplayScene(fileNamed: "GameplayScene")
        if let view = self.view as! SKView? {
            gameManager.egg.wearingHat = false
            scene?.scaleMode = .aspectFill
            scene?.viewController = self
            happiness.text = String("\(countHappiness())")
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        //        self.thoughtBubbleText.baselineAdjustment = .alignCenters;
        //        self.thoughtBubbleText.textAlignment = .center;
    }
    
    @IBAction func touchHatButton(_ sender: Any) {
        gameManager.egg.wearingHat = true
        updateTempLabel()
        scene?.eggSprite.hatEgg()
        self.touchHatVisual.isHidden = true
    }
    @IBAction func wake(_ sender: UIButton) {
        
        if ageActivated == true{
            return print("Age already active")
        }
        ageTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval/12, target: self, selector: (#selector(updateAge)), userInfo: nil, repeats: true)    //runs updateAge function once every 1 seconds. So one minute in time equals 1 day in age
        ageActivated = true
        hourTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval/24/12, target: self, selector: (#selector(updateHour)), userInfo: nil, repeats: true)
    }
    
    @IBAction func sleep(_ sender: UIButton) {
        ageTracker.invalidate()
        ageActivated = false
    }
    
    @IBAction func poo(_ sender: Any) {
        gameManager.lion.pooNow(innerFunction: {
            self.updateFoodMenuBar()
        })
        fillIceCreamArray()
        scene?.pooQuery()
        self.poopVisual.isHidden = true
    }
    
    @IBAction func dayButton(_ sender: Any) {
        scene?.makeNightBackground()
    }
    
    @IBAction func play(_ sender: Any) {
        if gameManager.lion.alive == false || gameManager.lion.born == false {
            return print("Dead kitty!")
        }
        
        spinAnimation()
        self.stomachContentsStatus(statement: "WHHEEEE!!!", bool: false)
        increaseHappiness()
    }
    
    func increaseHappiness(){
        if gameManager.lion.happy <= 30 {
            gameManager.lion.happy += 1
            print (gameManager.lion.happy)
            happiness.text = String("\(countHappiness())")
            playDays = 0
        }
    }
    
    func spinAnimation(){
        scene?.catSprite.flipCat(innerFunction:{
            if self.hungryDays > 4 {
                self.scene?.catSprite.animateSickCat()
            } else {
                self.scene?.catSprite.startIdleAnimation()
            }
        })
        
        print("I should be flipping!")
    }
    
    
    @IBAction func updatemeal(_ sender: Any) {
        gameManager.lion.eat(meal: "kiwi")
        stomachContentsStatus(statement: "Thank you for feeding me! >^_^<", bool: false)
        
        updateFoodMenuBar()
        cureHunger()
        
        //        if countStomachContents() >= 3 {
        //            self.poopVisual.isHidden = false
        //            return print("I'm full!")
        //        }
        //        if gameManager.lion.alive == false{
        //            return print("I'm dead kitty")
        //        }
    }
    
    func cureHunger(){
        if hungryDays > 4 && countStomachContents() >= 1{
            hungryDays = 0
            scene?.catSprite.stopSickCatAnimation()
        }
    }
    
    
    
    @objc func updateAge() {
        
        age += 1 //increments age every day
        ageLabel.text = String(age) //changes age text
        
        if gameManager.lion.born == true { //checks if lion is born
            playVersusHappyManager()
            hungerManager()
            chooseHungerStatement()
        }
        
        doAPooADay()
        tooMuchPoo()
        
        makeAHappyDay()
        angelAppearanceManager()
        
        scene?.increasePooAge()
        
    }
    
    func angelAppearanceManager(){
        if happyDays > 5 {
            scene?.angel.isHidden = false
        } else {
            scene?.angel.isHidden = true
        }
    }
    
    func makeAHappyDay(){
        if countHappiness() >= 10 {
            happyDays += 1 //increments number of days since played with
        } else {
            happyDays = 0 // happyDaysAreAStreak -- no losing a single day; if you msis one day, it's back to square ones
        }
    }
    
    func doAPooADay(){
        if countStomachContents() > 0 { //checks stomach contents
            gameManager.lion.pooNow(innerFunction: {
                self.updateFoodMenuBar()
                self.scene?.pooQuery()
                self.poopVisual.isHidden = true
            })
        }
    }
    
    func tooMuchPoo(){
        if scene!.pooCounter > 0 { //if it does then start counting poo
            gameManager.lion.happy -= 1 //subtract a happiness point for it
            happiness.text = String("\(countHappiness())") //print the result
        }
    }
    
    func playVersusHappyManager(){
        playDays += 1 //increments number of days since played with
        
        if playDays > 4 { //checks if there is now more than two
            gameManager.lion.happy -= 1 //subtracts a happiness point for it
            happiness.text = String("\(countHappiness())") //prints happiness
        }
    }
    
    func hungerManager(){
        if countStomachContents() < 2 { //checks stomach contents
            if countStomachContents() == 0 { // checks if nothing in there
                hungryDays += 1 // incremements hungry days
            }
            
            if hungryDays > 4 { // checks if 4 such days have passed
                scene?.catSprite.animateSickCat() //animates a sick cat
            }
            
            if hungryDays > 10 { //checks if more than 10 such days
                killCat()
            }
        }
    }
    
    func killCat(){
        scene?.catSprite.animateDeadCat() //kills cat animation
        ageTracker.invalidate() //stops time and all time related stuff
        hourTracker.invalidate()
        ageActivated = false //ends timerboolean
        gameManager.lion.alive = false //sets up flag to prevent anything that can happen if alive
        self.resetVisual.isHidden = false;
    }
    
    
    @objc func updateHour() {
        updateTempLabel() //updates temperature if changed
        hour += 1 //increments age every hour
        print("Hour incremented")
        hoursLabel.text = String(hour)  //changes age text
        if hour == 24 {
            hour = 0
        } else if hour == 20 {
            scene?.makeNightBackground()
            print("This Works Too")
        } else if hour == 6 {
            print("This Works 3")
            scene?.makeDayBackground()
        }
        
        if gameManager.egg.wearingHat == true && gameManager.lion.born == false { //checks if we're in egg-land, and wearing a hat
            gameManager.egg.temp += 1 // increements temperature if so
            if gameManager.egg.temp >= 18 { //hatches egg if that time
                gameManager.egg.wearingHat = false
                scene?.crackEgg() // cracks the egg animation
                happiness.text = String("\(countHappiness())") //prints happiness to screen
                self.happinessTitle.isHidden = false
                self.happiness.isHidden = false
            }
        }
    }
    
    
    func stomachContentsStatus(statement: String, bool: Bool){
        self.thoughtBubbleText.text = statement
        self.thoughtBubble.isHidden = bool
        self.thoughtBubbleText.isHidden = bool
    }
    
    func chooseHungerStatement(){
        if countStomachContents() == 0 {
            self.stomachContentsStatus(statement: "pweez feed me :'(", bool: false) //prints out what it needs
        } else if gameManager.lion.happy < 0 {
            self.stomachContentsStatus(statement: "I'm so sad :'(", bool: false)
        } else if playDays > 4 {
            self.stomachContentsStatus(statement: "I'm boooooored", bool: false)
        } else if scene!.pooCounter > 0 {
            self.stomachContentsStatus(statement: "It's starting to smell! :^(", bool: false)
        } else {
            self.stomachContentsStatus(statement: "", bool: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.hoursLabel.isHidden = true
        //        self.hoursTitle.isHidden = true
        creatureInteractionButtonsHidden(bool: true)
        self.thoughtBubbleText.textAlignment = .center;
        self.thoughtBubbleText.numberOfLines = 0
        foodUIHide(bool: true)
        updateTempLabel()
        
        ageTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval, target: self, selector: (#selector(updateAge)), userInfo: nil, repeats: true)
        hourTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval/24, target: self, selector: (#selector(updateHour)), userInfo: nil, repeats: true)
        hideAngel()
        
        if let view = self.view as! SKView? {
            scene?.scaleMode = .aspectFill
            scene?.viewController = self
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func hideEggUI(){
        self.tempLabel.isHidden = true
        self.thermometer.isHidden = true
    }
    
    func hideAngel() {
        scene?.angel.isHidden = true
    }
    func foodUIHide(bool: Bool){
        self.IceCreamOne.isHidden = bool
        self.IceCreamTwo.isHidden = bool
        self.IceCreamThree.isHidden = bool
        self.foodLabel.isHidden = bool
    }
    
    func fillIceCreamArray(firstIceCream: String? = "icecreamfour.png", secondIceCream: String? = "icecreamfour.png", thirdIceCream: String? = "icecreamfour.png"){
        IceCreamOne.image = UIImage(named: firstIceCream!)
        IceCreamTwo.image = UIImage(named: secondIceCream!)
        IceCreamThree.image = UIImage(named: thirdIceCream!)
    }
    
    
    func updateFoodMenuBar(){
        if countStomachContents() == 3{
            return fillIceCreamArray(firstIceCream: "icecreamone.png", secondIceCream: "icecreamtwo.png", thirdIceCream: "icecreamthree.png")
        }
        if countStomachContents() == 2{
            return fillIceCreamArray(firstIceCream: "icecreamone.png", secondIceCream: "icecreamtwo.png")
        }
        if countStomachContents() == 1 {
            return fillIceCreamArray(firstIceCream: "icecreamone.png")
        } else {
            fillIceCreamArray()
        }
    }
    
    
    func updateTempLabel(){
        tempLabel.text = "\(gameManager.egg.temp)°C"
    }
    
    func countStomachContents() -> Int {
        return gameManager.lion.stomachContents.count
    }
    
    func countHappiness() -> Int {
        return gameManager.lion.happy
    }
    
}

