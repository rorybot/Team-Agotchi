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
    @IBOutlet weak var feedVisual: UIButton!
    @IBOutlet weak var thoughtBubbleText: UILabel!
    @IBOutlet weak var thoughtBubble: UIImageView!
    @IBOutlet weak var happiness: UILabel!
    @IBOutlet weak var happinessTitle: UILabel!
    @IBOutlet weak var resetVisual: UIButton!
    @IBOutlet weak var playButton: UIButton!
    

    var ageActivated = true
    var ageTracker = Timer()
    var hourTracker = Timer()
    let constantTimeInterval = 12.0
    var gameManager: GameManager!
    var scene = GameplayScene(fileNamed: "GameplayScene")
    
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
    

    override func viewDidLoad() {
        self.resetVisual.isHidden = true;
        super.viewDidLoad()
        creatureInteractionButtonsHidden(bool: true)
        self.thoughtBubbleText.textAlignment = .center;
        self.thoughtBubbleText.numberOfLines = 0
        updateTempLabel()
        timeSetup()
        if let view = self.view as! SKView? {
            basicSKViewSetup(view: view)
        }
    }
    
    func timeSetup(){
        ageTracker = Timer()
        hourTracker = Timer()
        ageTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval, target: self, selector: (#selector(updateAge)), userInfo: nil, repeats: true)
        hourTracker = Timer.scheduledTimer(timeInterval: constantTimeInterval/24, target: self, selector: (#selector(updateHour)), userInfo: nil, repeats: true)
        hideAngel()
    }
    
    func creatureInteractionButtonsHidden(bool: Bool){
        self.feedVisual.isHidden = bool
        stomachContentsStatus(statement: "", bool: true)
        self.happinessTitle.isHidden = bool;
        self.happiness.isHidden = bool;
        self.playButton.isHidden = bool;
        self.IceCreamOne.isHidden = bool
        self.IceCreamTwo.isHidden = bool
        self.IceCreamThree.isHidden = bool
        self.foodLabel.isHidden = bool
    }
    
    func hideEggUI(bool: Bool){
        self.tempLabel.isHidden = bool
        self.thermometer.isHidden = bool
        self.touchHatVisual.isHidden = bool
    }

    @IBAction func resetGame(_ sender: Any) {
        super.viewDidLoad()
        
        gameManager.age = 0
        gameManager.hungryDays = 0
        gameManager.happyDays = 0
        
        ageLabel.text = String(gameManager.age)
        self.resetVisual.isHidden = true;
        creatureInteractionButtonsHidden(bool: true)
//        self.thermometer.isHidden = false;
//        self.touchHatVisual.isHidden = false;
//        self.tempLabel.isHidden = false;
        hideEggUI(bool: false)
        updateTempLabel()
        timeSetup()
        gameManager = GameManager()
        scene = GameplayScene(fileNamed: "GameplayScene")
        if let view = self.view as! SKView? {
            basicSKViewSetup(view: view)
        }
        //        self.thoughtBubbleText.baselineAdjustment = .alignCenters;
        //        self.thoughtBubbleText.textAlignment = .center;
    }
    
    func basicSKViewSetup(view: SKView){
        gameManager.egg.wearingHat = false
        scene?.scaleMode = .aspectFill
        scene?.viewController = self
        happiness.text = String("\(countHappiness())")
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
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
    }
    
//    @IBAction func dayButton(_ sender: Any) {
//        scene?.makeNightBackground()
//    }
    
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
            gameManager.playDays = 0
        }
    }
    
    func spinAnimation(){
        scene?.catSprite.flipCat(innerFunction:{
            self.scene?.postAnimationIntercept()
        })
        
        print("I should be flipping!")
    }
    
    
    @IBAction func updatemeal(_ sender: Any) {
        gameManager.lion.eat(meal: "kiwi")
        stomachContentsStatus(statement: "Thank you for feeding me! >^_^<", bool: false)
        
        updateFoodMenuBar()
        cureHunger()
    }
    
    func cureHunger(){
        if gameManager.hungryDays > 4 && countStomachContents() >= 1{
            gameManager.hungryDays = 0
            scene?.catSprite.stopSickCatAnimation()
        }
    }
    
    
    
    @objc func updateAge() {
        
        gameManager.age += 1 //increments age every day
        ageLabel.text = String(gameManager.age) //changes age text
        
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
        if gameManager.happyDays > 5 {
            scene?.angel.isHidden = false
        } else {
            scene?.angel.isHidden = true
        }
    }
    
    func makeAHappyDay(){
        if countHappiness() >= 10 {
            gameManager.happyDays += 1 //increments number of days since played with
        } else {
            gameManager.happyDays = 0 // happyDaysAreAStreak -- no losing a single day; if you msis one day, it's back to square ones
        }
    }
    
    func doAPooADay(){
        if countStomachContents() > 0 { //checks stomach contents
            gameManager.lion.pooNow(innerFunction: {
                self.updateFoodMenuBar()
                self.scene?.pooQuery()
//                self.poopVisual.isHidden = true
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
        gameManager.playDays += 1 //increments number of days since played with
        
        if gameManager.playDays > 4 { //checks if there is now more than two
            gameManager.lion.happy -= 1 //subtracts a happiness point for it
            happiness.text = String("\(countHappiness())") //prints happiness
        }
    }
    
    func hungerManager(){
        if countStomachContents() > 0 { //checks stomach contents
            return
        }
        gameManager.hungryDays += 1 // incremements hungry days
        chooseHungerAnimation()
    }
    
    func chooseHungerAnimation(){
        if gameManager.hungryDays > 4 { // checks if 4 such days have passed
            scene?.catSprite.animateSickCat() //animates a sick cat
        }
        
        if gameManager.hungryDays > 10 { //checks if more than 10 such days
            killCat()
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
        gameManager.hour += 1 //increments age every hour
        print("Hour incremented")
        hoursLabel.text = String(gameManager.hour)  //changes age text
        
        scene?.dayNightManager(hour: gameManager.hour)
        
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
    
//    func dayNightManager(hour: Int){
//        if hour == 24 {
//            gameManager.hour = 0
//        } else if gameManager.hour == 20 {
//            scene?.makeNightBackground()
//            print("This Works Too")
//        } else if gameManager.hour == 6 {
//            print("This Works 3")
//            scene?.makeDayBackground()
//        }
//    }
    
    
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
        } else if gameManager.playDays > 4 {
            self.stomachContentsStatus(statement: "I'm boooooored", bool: false)
        } else if scene!.pooCounter > 0 {
            self.stomachContentsStatus(statement: "It's starting to smell! :^(", bool: false)
        } else {
            self.stomachContentsStatus(statement: "", bool: true)
        }
    }
    
    func countStomachContents() -> Int {
        return gameManager.lion.stomachContents.count
    }

    
    func hideAngel() {
        scene?.angel.isHidden = true
    }
    func foodUIHide(bool: Bool){
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

    
    func countHappiness() -> Int {
        return gameManager.lion.happy
    }
    
}

