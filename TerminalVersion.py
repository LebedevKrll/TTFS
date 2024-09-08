

'''Terminal Version is the very first version of TTFS! it runs in your terminal
To run it download this file, start up cmd, then enter the folder where the game is
Then type "python TerminalVersion.py" and after that "Let's Go Gambling!"
If you are tired of gambling (shame on you) press ctrl+C'''

import random

class BJ:
    def __init__(self):
        self.intro = "Welcome to 'Gacha Casino'! (not to be confused with 'Gachi casino')\nIf you want to hear the rules type R\nIf you want to start profiting rapidly type $"
        self.rules = "To win a game of blackjack you have to get more scores than dealer, however if you get higher than 21 that's a loss.\n\
        Number cards cost exactly their number, face cards all cost 10 and ace can be 1 or 11.\n\
        The round starts with dealer and the Player both drawing 2 cards. Player's cards are opened immideatly, but dealer opens only one of their cards.\
        The Player then takes action. They can do the following:\n\
        Hit (type 'H'), which means drawing 1 more card.\n\
        Pat (type 'P'), which means not drawing.\n\
        Split (type 'S'), which means splitting your cards into 2 different games of blackjack (can be done only if Player has 2 cards of the same value).\n\
        After the Player pats its dealer's turn. Dealer follows specific instructions:\
        Hit if score dum is less than 16\n\
        Pat at 17 or higher\n\
        The deck is standart (for now), 4 suits: hearts, clubs, spades, diamonds, or just H, C, D, S, but they don't matter (for now), no jokers (for now)\n\
        If you were playing, but forgot something, you can always end the round by inputing 'Stop'\
        That should be it, have fun, fellow Gambler!"
        self.player = []
        self.dealer = []
        self.deck = ['H2', 'H3', 'H4', 'H5', 'H6', 'H7', 'H8', 'H9', 'H10', 'H10', 'H10', 'H10', 'H11', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C10', 'C10', 'C10', 'C11', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S10', 'S10', 'S10', 'S11', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D10', 'D10', 'D10', 'D11']
        self.discard = []
        self.dealer_in_text = []
        self.player_in_text = []
        self.deck_int_text = ['H2', 'H3', 'H4', 'H5', 'H6', 'H7', 'H8', 'H9', 'H10', 'HJ', 'HQ', 'HK', 'HA', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'CJ', 'CQ', 'CK', 'CA', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'SJ', 'SQ', 'SK', 'SA', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'DJ', 'DQ', 'DK', 'DA']
        self.discard_in_text = []
        # карты игрока | карты диллера | колода | сброс

    def LetsGoGambling(self):
        yield self.intro
        while True:
            action = input()
            if action not in "Rr$"
                yield "Excuse me, could you repeat that?"
            elif action in "Rr":
                yield self.rules
            else:
                while action != "Stop" or action != "sTOP" or action != "stop":
                    StartRound()
                    if not self.sog[1]:
                        Blackjack()
                    else:
                        while action != "Stop" or action != "sTOP" or action != "stop":
                            action = input()
                            if action not in 'HPShps' or action not in ['hit', 'Hit', 'hIT', 'Pat', 'pat', 'pAT', 'split', 'Split', 'sPLIT']:
                                yield "Excuse me, could you repeat that?"
                            else:
                                ApplyAction(action)
    
    def StartRound(self):
        PlayerCards = [self.sog[2][random.randrange(len(self.sog))], self.sog[2][random.randrange(len(self.sog) - 1)]]
        if int(PlayerCards[0]) + int(PlayerCards[1]) == 21:
            return
        self
        

    def ApplyAction(self, action):


    def Blackjack(self):
        yield "Congrats! That's a blackjack! Pure skill, honestly"
        # мб нет смысла под крайний случай целую функцию выделять, но кому не пофигу

while True:
    ritual = input()
    if ritual == "Let's Go Gambling!":
        while True:
            LetsGoGambling()
    elif ritual == "Credits":
        print("HighMistick aka LebedevKrll")