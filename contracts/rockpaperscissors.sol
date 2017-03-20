contract rockpaperscissors
{
    mapping (string => mapping(string => int)) scoreMatrix;
    address player1;
    address player2;
    string public player1Choice;
    string public player2Choice;

    modifier unRegistered()
    {
        if (msg.sender == player1 || msg.sender == player2)
            throw;
        else
            _
    }
    
    modifier sentEnoughCash(uint amount)
    {
        if (msg.value < amount)
            throw;
        else
            _
    }
    
    function rockpaperscissors() 
    {   // constructor
        scoreMatrix["rock"]["rock"] = 0;
        scoreMatrix["rock"]["paper"] = 2;
        scoreMatrix["rock"]["scissors"] = 1;
        scoreMatrix["paper"]["rock"] = 1;
        scoreMatrix["paper"]["paper"] = 0;
        scoreMatrix["paper"]["scissors"] = 2;
        scoreMatrix["scissors"]["rock"] = 2;
        scoreMatrix["scissors"]["paper"] = 1;
        scoreMatrix["scissors"]["scissors"] = 0;
    }
    
    function getWinner() constant returns (int x)
    {
        return scoreMatrix[player1Choice][player2Choice];
    }
    
    function play(string choice) returns (int w)
    {
        if (msg.sender == player1)
            player1Choice = choice;
        else if (msg.sender == player2)
            player2Choice = choice;
        if (bytes(player1Choice).length != 0 && bytes(player2Choice).length != 0)
        {
            int winner = scoreMatrix[player1Choice][player2Choice];
            if (winner == 1)
                player1.send(this.balance);
            else if (winner == 2)
                player2.send(this.balance);
            else
            {
                player1.send(this.balance/2);
                player2.send(this.balance);
            }
             
            // unregister players and choices
            player1Choice = "";
            player2Choice = "";
            player1 = 0;
            player2 = 0;
            return winner;
        }
        else 
            return -1;
    }
    

    function getBalance () constant returns (uint amount)
    {
        return msg.sender.balance;
    }
    
    function getContractBalance () constant returns (uint amount)
    {
        return this.balance;
    }
    
    function register()
        sentEnoughCash(5)
        unRegistered()
    {
        if (player1 == 0)
            player1 = msg.sender;
        else if (player2 == 0)
            player2 = msg.sender;
    }
    
    function isPlayer1() constant returns (bool x)
    {
        return msg.sender == player1;
    }
    
    function isPlayer2() constant returns (bool x)
    {
        return msg.sender == player2;
    }

    
    function checkNotNull() constant returns (bool x)
    {
         return (bytes(player1Choice).length==0 && bytes(player2Choice).length==0);
    }

}
