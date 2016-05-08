### cardmatch_ios
iOS based card matching memory game in Objective-C

This is a simple card game to try out colour memory. The game board consists of a 4x4 grid with 8 pairs of color cards.
The game starts initially with all cards facing down. The player is to then flip two cards each round, trying to find a match. If the flipped pair is a match, the player receives two (2) points, and the cards may be removed from the game board. Otherwise, the cards are turned face- down again and the player loses one (1) point. This continues until all pairs have been found.
After the game is finished, the user is prompted to input his/her name. The user's name and the score would then be stored and **syncrhonised to an [online highscore board](https://github.com/coder9t99/cardmatch_rest_api)**.

This game supports **iOS version 8.0+** and runable on both **iPhone** and **iPad**. (as well as simulator..)

### Features
- The game board is displayed in portrait orientation only.
- After each round, a brief one (1) second pause before dismissing to allow the player to see what the second selected card is.
- There is a simple validation to user's name for highscore. (no empty inputs, not event white spaces)
- Clicking the High Scores button takes the user to the table of high scores.
- For simplicity look and feel, the high scores table ise displayed in portrait orientation.
- All high scores is persisted using CoreData (with sqlite).
- User can turn off online sync from iOS Settings.
- When online sync is turned off, High scores is stored and persist as long as the user does not uninstall the app or clear the app's stored data.

### Overview
![Alt text](CardMatch.png?raw=true "Overview Diagram")

#### AppDelegate
Orchestrates view hierarchy as well as initiates SettingsWatcher to handle setting changes.

#### ViewController
Serve as the face of underlying game logic component -- CardMatch. Presents Gameboard of cards to interacts with the user.

#### HighScoreViewController
Presents high scores from the local data store. Which may be synchronised with HighScore Rest API

#### CardMatch
Game logic component. Expose `- (void)start;` and `- (BOOL)match:(NSUInteger)cardPos1 with:(NSUInteger)cardPos2;`

`- (void)start;`
starts / restarts the game shuffles card data and resets the current score

`- (BOOL)match:(NSUInteger)cardPos1 with:(NSUInteger)cardPos2;`
Matches card on supplied positions. +2 to current score if match, else -1 to current score.

#### SettingsWatcher
Observe Settings user settings defaults. Depending on actual setting, may trigger HighScoreSynchroniser accordingly.

#### HighScore Local Store
CoreData (sqlite based) data repo.

#### HighScore Synchroniser
Synchronises data between local store and HighScore RestAPI

#### HighScore RestAPI
Cloud-based HighScore RESTful API. For further information, check [this link out](https://github.com/coder9t99/cardmatch_rest_api).
