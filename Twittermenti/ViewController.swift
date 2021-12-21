//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    let sentimentClassifier=TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "PKxwEOVcLO89YkGUjWpzJR7ff", consumerSecret: "JZehglHEkRUQ8Kb7gDnoeoYhIyoiHpKJPols5ZqUM622JkFJ9T")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sentimentLabel.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        sentimentLabel.text = "Let's Predict The Future"
        textField.delegate = self
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        if textField.text == ""{
            let alert = UIAlertController(title: "Please Enter Tweet", message: "Empty Fields are quite Unpredictable :)", preferredStyle: .alert)
            let action = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }else{
            sentimentLabel.text = ""
            sentimentLabel.font = UIFont.systemFont(ofSize: 100)
            fetchTweets()
            
        }
    }
    func fetchTweets() {
        
        if let label = textField.text{
            let vc = LoaderViewController()
            guard let loaderView = vc.view else{
                fatalError("Unable to Fetch View")
            }
            view.addSubview(loaderView)
            vc.showView()
            swifter.searchTweet(using: "\(label) exclude:retweets",lang: "en", count: 100 , tweetMode: .extended ,success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForInput=TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForInput)
                    }
                }
                vc.hideView()
                self.performSentiment(with: tweets)
            } ) { (error) in
                print("Error Fetching Data from twitter API\(error)")
            }
        }
        
    }
    
    func performSentiment(with tweets:[TweetSentimentClassifierInput]) {
        do {
            var sentimentScore = 0
            let prediction = try self.sentimentClassifier.predictions(inputs: tweets)
            for pred in prediction {
                let sentiment=pred.label
                if sentiment == "Pos"{
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            updateUI(with: sentimentScore)
            
        } catch {
            print("Error Analysing Tweets,\(error)")
        }
        
    }
    func updateUI(with sentimentScore:Int) {
        if sentimentScore>20 {
            sentimentLabel.text = "😍"
        } else if sentimentScore>10 {
            sentimentLabel.text = "😄"
        } else if sentimentScore>0 {
            sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            sentimentLabel.text = "🤨"
        } else if sentimentScore > -10 {
            sentimentLabel.text = "🥺"
        } else if sentimentScore > -20 {
            sentimentLabel.text = "😢"
        } else {
            sentimentLabel.text = "😭"
        }
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        predictPressed(self)
        textField.resignFirstResponder()
        return true
    }
}

