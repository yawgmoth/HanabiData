## Synopsis

This repository contains game logs for a browser-based implementation of [Hanabi](https://boardgamegeek.com/boardgame/98778/hanabi) obtained from an experiment we performed to test the performance of our Intentional Hanabi AI. The data set itself can be of interest to researchers or other interested individuals who want to improve upon our work, or implement a completely different AI for Hanabi. Note that our implementation can also be used to watch replays of the game logs available in this data set, and is available [on Github](https://github.com/yawgmoth/pyhanabi).

## Format

The data set consists of game logs and survey answers from participants in our experiment that agreed to the publication of that data. Every participant filled out the survey only once, but could play multiple times. Each game got a unique ID and is in a file `game<ID>.log` where `<ID>` is replaced with that ID. Additionally, for the first game every participant played, there is a file `survey<ID>.log` containing their survey answers. The survey questions were as follows:

* Question: What is your age? (question ID: age)
  Answers:
    + 18-29 years (answer ID: 20s)
    + 30-39 years (answer ID: 30s)
    + 40-49 years (answer ID: 40s)
    + 50-64 years (answer ID: 50s)

* Question: How familiar are you with the board and card games in general? (question ID: bgg)  
  Answers:
     + I never play board or card games (answer ID: new)
     + I rarely play board or card games (answer ID: dabbling)
     + I sometimes play board or card games (answer ID: intermediate)
     + I often play board or card games (answer ID: expert)
        
* Question: Do you consider yourself to be a (board) gamer? (question ID: gamer)  
  Answers:
     + Yes (answer ID: yes)
     + No (answer ID: no)

* Question: How familiar are you with the card game Hanabi? (question ID: exp)  
  Answers:
     + I have never played before participating in this experiment (answer ID: new)
     + I have played a few (1-10) times (answer ID: dabbling)
     + I have played multiple (10-50) times (answer ID: intermediate)
     + I have played many (> 50) times (answer ID: expert)
        
* Question: When was the last time that you played Hanabi before this experiment? (question ID: recent)  
  Answers:
     + I have never played before or can't remember when I played the last time (answer ID: never)
     + The last time I played has been a long time (over a year) ago (answer ID: long)
     + The last time I played has been some time (between 3 months and a year) ago (answer ID: medium)
     + The last time I played was recent (up to 3 months ago) (answer ID: recent)

* Question: How often do you typically reach the top score of 25 in Hanabi? (question ID: score)  
  Answers:
     + I never reach the top score, or I have never played Hanabi (answer ID: never)
     + I almost never reach the top score (about one in 50 or more games) (answer ID: few)
     + I sometimes reach the top score (about one in 6-20 games) (answer ID: sometimes)
     + I often reach the top score (about one in 5 or fewer games) (answer ID: often)

* Question: For this study we have recorded your answers to this survey, as well as a log of actions that you performed in the game. We have <b>not</b> recorded your IP address or any other information that could be linked back to you. Do you agree that we make your answers to the survey and the game log publicly available for future research? (question ID: publish)  
  Answers:
     + Yes (answer ID: yes)
     + No (answer ID: no)

* Question: How intentional/goal-directed did you think this AI was playing? (question ID: intention)  
  Answers:
     + Never performed goal-directed actions (answer ID: 1)
     + Rarely performed goal-directed actions (answer ID: 2)
     + Sometimes performed goal-directed actions (answer ID: 3)
     + Often performed goal-directed actions (answer ID: 4)
     + Always performed goal-directed actions (answer ID: 5)
    
* Question: How would you rate the play skill of this AI? (question ID: skill)  
  Answers:
     + The AI played very badly (answer ID: vbad)
     + The AI played badly (answer ID: bad)
     + The AI played ok (answer ID: ok)
     + The AI played well (answer ID: good)
     + The AI played very well (answer ID: vgood)
        
* Question: How much did you enjoy playing with this AI? (question ID: like)  
  Answers:
     + I really disliked playing with this AI (answer ID: vhate)
     + I somewhat disliked playing with this AI (answer ID: hate)
     + I neither liked nor disliked playing with this AI (answer ID: neutral)
     + I somewhat liked playing with this AI (answer ID: like)
     + I really liked playing with this AI (answer ID: vlike)

The `survey<ID>.log` files contain one line for every question answered by the participant containing the question ID and answer ID separated by a space. Note that not all participants answered all questions, but all surveys available in this data set answered the question with the ID "publish" with "yes".

Each `game<ID>.log` file describes a completed game of Hanabi. If it was not the first game a participant played, the first line in the file will start with `Old GID:` followed by a previous game that participant played (as participants may bookmark their "play again" links, this may not necessarily be the immediately preceding game. To determine game order, use the file modification date.) Each file then contains a line starting with `Treatment:` followed by the name of an AI and a random seed in parenthesis. From the random seed it is possible to determine the order of cards in the deck, with the python code:

```python
def make_deck(seed):
    random.seed(seed)
    deck = []
    for col in ["green", "yellow", "white", "blue", "red"]:
        for num, cnt in enumerate([3,2,2,2,1]):
            for i in xrange(cnt):
                deck.append((col, num+1))
    random.shuffle(deck)
    return deck
```

The file also contains the vector of cards remaining in the deck after both players have drawn their hand as the next line. The rest of the file consists of a description of the actions taken by the players. Lines starting with `MOVE:` contain all information needed to reconstruct the action, all others just contain the action in plain English. The format for the `MOVE:` lines is:

```MOVE: <Player> <Action> <Card> <Target> <Color> <Rank>```

where `<Player>` is the index of the player performing the action, and `<Action>` is an integer between 0 and 3 describing which action was performed. The value of `<Action>` determines which other parameters are used. Unused parameters are set to `None`. The possible actions are:
* `<Action> == 0`: Hint the `<Target>` player about all cards of `<Color>`
* `<Action> == 1`: Hint the `<Target>` player about all cards of `<Rank>`
* `<Action> == 2`: Play card at hand index `<Card>`
* `<Action> == 3`: Discard card at hand index `<Card>`

The game log concludes with a line starting with `Score:` followed by the final score the players reached. For an example on how to use the game log files to replay games, refer to [our implementation](https://github.com/yawgmoth/pyhanabi)

Finally, we provide `extract.py` to demonstrate how to extract the data from the survey files and game logs and write them to csv suitable for processing with e.g. R.

## Contributors

The Hanabi AIs and browser-based UI were implemented by Markus Eger, under the supervison of Dr. Chris Martens in the Principles of Expressive Machines Lab at North Carolina State University. Learn more about our lab on [our website](https://sites.google.com/ncsu.edu/poem/)

## License

This work is licensed under a Creative Commons Attribution 4.0 International License. For more information refer to [the license file](LICENSE) and [https://creativecommons.org/licenses/by/4.0/]