/* Contract to Register Device to the BlockChain */
contract RegisterDevice{

struct device{
		address deviceAddr; //device ethereum address
	   	bytes32 devicePubKey; // public key of the device	
    	bytes32 managerPubKey;
    	//bytes memory storageHash; // IPFS storage hash returned by the API, memory = temporary storage in the contract
}
	//only manager allowed to do admin stuff such as adding access, etc.
	address _managerAddr;
    mapping (address => bytes32) deviceInfo; //address to public key mapping
    mapping (address => address) deviceManagerInfo; // device to manager mapping
    mapping (bytes32 => bytes32) accessList; // public key => (device)
    Device device;


    /*Generates a public event on the blockchain that will notify clients */
    event DeviceAdded(address indexed deviceAddr, address indexed manaderAddr); //event broadcast mappings?
    event AccessListAdded(address indexed deviceaddr);

 	/* Constructor */
 	function RegisterDevice(address _deviceAddr, bytes32 _devicePubKey, bytes32 _managerPubKey){
 		_managerAddr = msg.sender;
 		deviceAddr = _deviceAddr;
 		devicePubKey = _devicePubKey;
 		deviceInfo [deviceAddr] = devicePubKey;
 		setManager(msg.sender, _managerPubKey);
 		addAccessList();
 	}

 	/* Set the manager for this device */
	function setManager(address _managerAddr, bytes32 initKey) {
	    if(_managerAddr != 0x0 && msg.sender != _managerAddr) throw;
		deviceManagerInfo [deviceAddr] = _managerAddr;
		devicePubKey = initKey;
	}

	/* Checks whether sender is manager */
	function isManager() constant returns (bool isManager){
		return (msg.sender == _managerAddr);
	}

	/* Manager pushes ACL to blockchain */
	function addAccessList() returns (int result){
		if(!isManager()) {
			result = 0;
		}
		else{
		//TODO how will the damn push happen?
		AccessListAdded(_manageraddr);
		result = 1;
		}
	}  

	function isAccess(bytes32 _devicePubKey1, bytes32 _devicePubKey2) returns (bool isAccess){
		return (accessList[_devicePubKey1] == _devicePubKey2);

	} 

	// Kill the contract
	function deleteDevice(){
		if(isManager()){
		delete device;
		suicide(_managerAddr);
		}
	}

}


/**

* Devices have their ethereum addresses translated to a UNIQUE name (name registrar)
* Names have to be added to blockchain
* ACL is to be added to the the blockchain
* Have to be able to access ACL from previous blocks

**/