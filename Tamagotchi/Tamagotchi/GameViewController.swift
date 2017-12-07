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
    var hourlyFunctions: [()] = []
    
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
        self.stomachContentsStatus(hidden: true)
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
        scene?.eggSprite.hatEgg()
        self.touchHatVisual.isHidden = true
    }
    
    @IBAction func play(_ sender: Any) {
        if gameManager.lion.alive == false || gameManager.lion.born == false {
            return print("Dead kitty!")
        }
        
        spinAnimation()
        self.stomachContentsStatus(statement: "WHHEEEE!!!")
        increaseHappiness()
    }
    
    func increaseHappiness(){
        if gameManager.lion.happy <= 30 {
            editHappy(amount: 1)
            gameManager.boredomDays = 0
        }
    }
    
    func spinAnimation(){
        scene?.catSprite.flipCat(innerFunction:{
            self.scene?.postAnimationIntercept()
        })
    }
    
    
    @IBAction func updatemeal(_ sender: Any) {
        guard countStomachContents() == 3 else {
        gameManager.lion.eat(meal: "kiwi")
        stomachContentsStatus(statement: "Thank you for feeding me! >^_^<")
        fillIceCreamMenu()
        cureHunger()
            return print(countStomachContents())
        }
    }
    
    func cureHunger(){
        if gameManager.hungryDays > 4 && countStomachContents() >= 1{
            gameManager.hungryDays = 0
            scene?.catSprite.stopSickCatAnimation()
        }
    }
    
    
    
    @objc func updateAge() {
        gameManager.age += 1
        ageLabel.text = String(gameManager.age)
        
        if gameManager.lion.born == true {
            dailyTasks()
        }
        
    }
    
    func crackThatEgg() {
        scene?.crackEgg(innerFunction: {
                self.creatureInteractionButtonsHidden(bool: false)
                self.hideEggUI(bool: true)
            })
    }
    
    func incubateUnlessBorn(){
        print(gameManager.lion.born)
        guard gameManager.lion.born == true else {
            gameManager.egg.incubate(innerFunction: {
                self.crackThatEgg()
                self.hourlyFunctions.removeLast()
                })
            return updateTempLabel()
        }
    }
    
    @objc func updateHour() {
        updateTempLabel() //updates temperature if changed
        gameManager.hour += 1 //increments age every hour
        hoursLabel.text = String(gameManager.hour)  //changes age text
        
        hourlyFunctions = [(scene?.dayNightManager(hour: gameManager.hour))!, incubateUnlessBorn()]
    }
    
    func dailyTasks(){
        increaseBoredomDaysUntilSadness()
        hungerManager()
        chooseHungerStatement()
        doAPooADay()
        tooMuchPoo()
        happyDayStreakIncrementor()
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
    
    func happyDayStreakIncrementor(){
        if countHappiness() >= 10 { return gameManager.happyDays += 1
        } else {
            gameManager.happyDays = 0
        }
    }
    
    func doAPooADay(){
        if countStomachContents() > 0 { //checks stomach contents
            gameManager.lion.pooNow(innerFunction: {
                self.fillIceCreamMenu()
                self.scene?.pooQuery()
                self.fillIceCreamMenu(fill: false)
            })
        }
    }
    
    func tooMuchPoo(){
        guard scene!.pooCounter < 1 else {
            return editHappy()
        }
    }
    
    func increaseBoredomDaysUntilSadness(){
        gameManager.boredomDays += 1
        if gameManager.boredomDays > 4 {
            editHappy()
        }
    }
    
    func editHappy(amount: Int = -1){
        gameManager.lion.happy += amount
        happiness.text = String("\(countHappiness())")
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
        scene?.catSprite.animateDeadCat()
        ageTracker.invalidate()
        hourTracker.invalidate()
        ageActivated = false
        gameManager.lion.alive = false
        self.resetVisual.isHidden = false
    }
    

    
    func stomachContentsStatus(statement: String? = "", hidden: Bool? = false){
        self.thoughtBubbleText.text = statement
        self.thoughtBubble.isHidden = hidden!
        self.thoughtBubbleText.isHidden = hidden!
    }
    
    func chooseHungerStatement(){
        if countStomachContents() == 0 {
            self.stomachContentsStatus(statement: "pweez feed me :'(")
        } else if gameManager.lion.happy < 0 {
            self.stomachContentsStatus(statement: "I'm so sad :'(")
        } else if gameManager.boredomDays > 4 {
            self.stomachContentsStatus(statement: "I'm boooooored")
        } else if scene!.pooCounter > 0 {
            self.stomachContentsStatus(statement: "It's starting to smell! :^(")
        } else {
            self.stomachContentsStatus(hidden: true)
        }
    }
    
    func countStomachContents() -> Int {
        return gameManager.lion.stomachContents.count
    }
    
    func hideAngel() {
        scene?.angel.isHidden = true
    }
    
    func fillIceCreamMenu(fill: Bool? = true){
        let iceCreamMenu = [IceCreamOne, IceCreamTwo, IceCreamThree]
        let iceCreamImages = ["icecreamone.png", "icecreamtwo.png", "icecreamthree.png"]
        if fill == true {
            for i in 0..<(countStomachContents()) {
                iceCreamMenu[i]?.image = UIImage(named: iceCreamImages[i])
            }
        } else {
            iceCreamMenu[countStomachContents()]?.image = UIImage(named: "icecreamfour.png")
        }
    }

    func updateTempLabel(){
        tempLabel.text = "\(gameManager.egg.temp)°C"
    }
    
    func countHappiness() -> Int {
        return gameManager.lion.happy
    }
}

