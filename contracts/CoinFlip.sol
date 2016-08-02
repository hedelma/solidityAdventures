contract CoinFlip{ //returns a random number

address public creator;

 	  /* Generates a random number from 0 to 100 based on the last block hash */
    function randomGen(uint seed) constant returns (uint randomNumber) {
        return(uint(sha3(block.blockhash(block.number-1), seed ))%100);
    }

    /* generates a number from 0 to 2^n based on the last n blocks*/ 
    function multiBlockRandomGen(uint seed, uint size) constant returns (uint randomNumber) {
        uint n = 0;
        for (uint i = 0; i < size; i++){
            if (uint(sha3(block.blockhash(block.number-i-1), seed ))%2==0)
                n += 2**i;
        }
        return n;
    }

 	function CoinFlip(){
		creator = msg.sender;
 	}

 	function kill(){
		suicide(creator);
 	}
}


/*
var coinflipContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"creator","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"seed","type":"uint256"},{"name":"size","type":"uint256"}],"name":"multiBlockRandomGen","outputs":[{"name":"randomNumber","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"seed","type":"uint256"}],"name":"randomGen","outputs":[{"name":"randomNumber","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"}]);
var coinflip = coinflipContract.new(
   {
     from: web3.eth.accounts[3], 
     data: '606060405260008054600160a060020a0319163317905560e6806100236000396000f3606060405260e060020a600035046302d05d3f8114603857806341c0e1b514605657806341fa4876146073578063434b14e71460ba575b005b60d460005473ffffffffffffffffffffffffffffffffffffffff1681565b603660005473ffffffffffffffffffffffffffffffffffffffff16ff5b60d4600435602435600080805b8381101560de5743819003600019014060609081526080869052604090206002900683141560b3578060020a8201915081505b6001016080565b436000190140606090815260043560805260409020606490065b6060908152602090f35b50939250505056', 
     gas: 4700000
   }, function (e, contract){
    console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })