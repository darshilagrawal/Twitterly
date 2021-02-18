

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
        
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    func fetchTweets(){
        
        
        if let label=textField.text{
            
            swifter.searchTweet(using: "\(label) exclude:retweets",lang: "en", count: 100 , tweetMode: .extended ,success: { (results, metadata) in
                
                var tweets=[TweetSentimentClassifierInput]()
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForInput=TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForInput)
                    }
                }
                self.performSentiment(with: tweets)
            } ) { (error) in
                print("Error Fetching Data from twitter API\(error)")
            }
            
        }
        
    }
    
    func performSentiment(with tweets:[TweetSentimentClassifierInput]){
        do{
            var sentimentScore=0
            let prediction=try self.sentimentClassifier.predictions(inputs: tweets)
            for pred in prediction{
                let sentiment=pred.label
                if sentiment=="Pos"{
                    sentimentScore += 1
                }else if sentiment=="Neg"{
                    sentimentScore -= 1
                }
            }
            updateUI(with: sentimentScore)
            
        }catch{
            print("Error Analysing Tweets,\(error)")
        }
        
    }
    func updateUI(with sentimentScore:Int){
        if sentimentScore>20{
            sentimentLabel.text="😍"
        }else if sentimentScore>10{
            sentimentLabel.text="😄"
        }else if sentimentScore>0{
            sentimentLabel.text="🙂"
        }else if sentimentScore == 0{
            sentimentLabel.text="🤨"
        }else if sentimentScore > -10{
            sentimentLabel.text="🥺"
        }else if sentimentScore > -20{
            sentimentLabel.text="😢"
        }else{
            sentimentLabel.text="😭"
        }
        
    }
    
}

