  contract SchedulerAPI {
    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint targetBlock) public returns (address);
}

  contract IntegratedContract{

      //custom data types 
      struct Device{
        uint deviceNumber;
        address deviceAddr; //device ethereum address
        bytes32 devicePubKey; // public key of the device  

     }

      struct AccessList{
        bytes32 accessPubKey; 
        bytes32 resource;
        uint accessType; //1: read, 2: write, 3: both
        uint expirationTime;

     }

     struct ManagerList{
        bytes32 managerPubKey;
        address addedBy; 

     }

     uint deviceCounter; 
     uint managerCounter;
     address creator;   

     //global data stores    
     Device[] public mobileDevices;
     mapping(bytes32 => AccessList[]) accessListMap;
     mapping(bytes32 => ManagerList[]) managerListMap;
     mapping (address => bool) public deviceAddressPresent;
     mapping(bytes32 => bool) public devicePubKeyPresent;

     address constant scheduler = SchedulerAPI(0xe109ecb193841af9da3110c80fdd365d1c23be2a);

     //broadcasting messages
     event DeviceAdded(
      uint indexed number, 
      address indexed deviceAddr
      );

     event DeviceRemoved(
      bytes32 indexed devicePubKey
      );

     event PolicyAdded(
      bytes32 indexed deviceKey, 
      bytes32 indexed accessKey, 
      uint indexed accessType
      );

     event PolicyRemoved(
      bytes32 indexed deviceKey, 
      bytes32 indexed accessKey
      );

     event ManagerAdded(
      bytes32 indexed deviceKey, 
      bytes32 indexed managerKey
      );

     event ManagerRemoved(
      bytes32 indexed deviceKey, 
      bytes32 indexed managerKey
      );

     //default constructor
     function IntegratedContract(){

      creator = msg.sender;
     }

    //add new device
    function setDevice(address _deviceAddr, bytes32 _devicePubKey) 
    returns (bool success){

        if((deviceAddressPresent[_deviceAddr] == true) && 
          devicePubKeyPresent[_devicePubKey] == true){
          return false;
        }

        Device memory newDevice;
        newDevice.deviceAddr = _deviceAddr;
        newDevice.devicePubKey = _devicePubKey;
        newDevice.deviceNumber = deviceCounter++;  
        //changing state of the array
        mobileDevices.push(newDevice); 
        deviceAddressPresent[_deviceAddr] = true;
        devicePubKeyPresent[_devicePubKey] = true;
        DeviceAdded(deviceCounter, _deviceAddr);
        return true;

     }

    //get device address or check if device exists
    function getDevice(bytes32 _devicePub) 
    constant returns (bool, address){

        uint length = mobileDevices.length; 
        for (uint i = 0; i < length; i++) {
          Device memory currentDevice = mobileDevices[i];
          if(_devicePub == currentDevice.devicePubKey && 
            devicePubKeyPresent[currentDevice.devicePubKey] == true){
              return (true, currentDevice.deviceAddr);
          }
        }
        return(false,0x0);
     }
     
    //get all devices registered
    function getAllDevices() 
    constant returns (uint[], address[], bytes32[]){

        uint length = mobileDevices.length;
        uint[] memory deviceNumbers = new uint[](length);
        address[] memory deviceAddresses = new address[](length);
        bytes32[] memory devicePubKeys = new bytes32[](length);

        for (uint i = 0; i < length; i++) {
           Device memory currentDevice;
           currentDevice = mobileDevices[i];
           deviceNumbers[i] = currentDevice.deviceNumber;
           deviceAddresses[i] = currentDevice.deviceAddr;
           devicePubKeys[i] = currentDevice.devicePubKey;

        }

    return(deviceNumbers,deviceAddresses,devicePubKeys); //return the tuple
    }

    //delete one device at a time
    function deleteDevice(bytes32 _deviceKey) 
    returns (bool success){

      if((devicePubKeyPresent[_deviceKey]) == false){ 
        return false;
      }
      uint length = mobileDevices.length;
      for (uint i = 0; i < length-1; i++) {
          if( mobileDevices[i].devicePubKey == _deviceKey){
            mobileDevices[i] = mobileDevices[i+1];
        }
      }

      delete mobileDevices[length-1];
      mobileDevices.length--;
      DeviceRemoved(_deviceKey);
      return true;
    }

    //check if manager of a particular device
    function isManager(bytes32 _devicePubKey, bytes32 _managerPubKey) 
    constant returns (bool){

      ManagerList[] memory currentList;
      currentList = managerListMap[_devicePubKey];
      uint length = currentList.length;

      for (uint i = 0; i < length; i++) {
        if (managerListMap[_devicePubKey][i].managerPubKey == _managerPubKey){
          return true;
        }
      }
      return false;
    }
    
    

     //adding multiple managers to one device
     function setManager(bytes32 _devicePubKey, bytes32 _managerPubKey) 
     returns (bool success){

      if((devicePubKeyPresent[_devicePubKey] == false) && 
        (isManager(_devicePubKey,_managerPubKey) == true)){ 
        return false;
      }

      managerListMap[_devicePubKey].push(ManagerList(_managerPubKey,msg.sender)); 
      ManagerAdded(_devicePubKey,_managerPubKey);
      return true;
     }

    //check corresponding manager list
    function getManager(bytes32 _devicePubKey) 
    constant returns (bytes32[], address[]){

        ManagerList[] memory currentList;
        currentList = managerListMap[_devicePubKey];
        uint length = currentList.length;
        bytes32[] memory managerKeys = new bytes32[](length);
        address[] memory addedBy = new address[](length);
      
        for (uint i = 0; i < length; i++) {
          managerKeys[i] = managerListMap[_devicePubKey][i].managerPubKey;
          addedBy[i] = managerListMap[_devicePubKey][i].addedBy;
        }

        return(managerKeys,addedBy);
    }

    //delete manager of a particular device
    function deleteManager(bytes32 _devicePubKey, bytes32 _managerKey) 
    returns (bool){

      if(isManager(_devicePubKey, _managerKey) == false){
        return false;
      }
      ManagerList[] memory currentList;
      currentList = managerListMap[_devicePubKey];

      for (uint i = 0; i < currentList.length; i++) {
        if(managerListMap[_devicePubKey][i].managerPubKey == _managerKey){
          delete managerListMap[_devicePubKey][i];
          ManagerRemoved(_devicePubKey,_managerKey);
        }
      }
      
      return true;
    }

    //check if the access exists
    function isRule(bytes32 _devicePubKey, bytes32 _accesskey) 
    constant returns (bool){

      AccessList[] memory currentList;
      currentList = accessListMap[_devicePubKey];
for (uint i = 0; i < currentList.length; i++) {
        if (accessListMap[_devicePubKey][i].accessPubKey == _accesskey){
          return true;
        }
      }

      return false;
    }

    //add new access rules
    function setRules(bytes32 _devicePub, bytes32 _accessPub, bytes32 resource, uint _accessType, uint expirationTime) 
    returns (bool){
        
        if(devicePubKeyPresent[_devicePub] == false){ 
          return false;
        }
        accessListMap[_devicePub].push(AccessList(_accessPub,resource,_accessType, expirationTime));
        //TODO check if the expiration time has expired and update the accessListMap
        PolicyAdded(_devicePub,_accessPub,_accessType);
        return true;
     }

    //list of all rules for a specific device
    function getRules(bytes32 _devicePubKey) 
    constant returns (bytes32[], bytes32[], uint[],uint[]){

        AccessList[] memory currentList;
        currentList = accessListMap[_devicePubKey];
        uint length = currentList.length;
        bytes32[] memory accessPubKeys = new bytes32[](length);
        bytes32[] memory resources = new bytes32[](length);
        uint[] memory accessTypes = new uint[](length);
        uint[] memory expirationTimes = new uint[](length);

        for (uint i = 0; i < length; i++) {

          accessPubKeys[i] = accessListMap[_devicePubKey][i].accessPubKey;
          resources[i] = accessListMap[_devicePubKey][i].resource;
          accessTypes[i] = accessListMap[_devicePubKey][i].accessType;
          expirationTimes[i] = accessListMap[_devicePubKey][i].expirationTime;
          
        }
        return(accessPubKeys,resources,accessTypes,expirationTimes);      
    }

    //delete one rule at a time for a device
    function deleteRules(bytes32 _devicePubKey, bytes32 _accesskey) 
    returns (bool){ 

      if((devicePubKeyPresent[_devicePubKey] == false)){ 
          return false;
      }
      AccessList[] memory currentList;
      currentList = accessListMap[_devicePubKey];

      for (uint i = 0; i < currentList.length; i++) {
          if(accessListMap[_devicePubKey][i].accessPubKey == _accesskey){
            delete accessListMap[_devicePubKey][i];
            PolicyRemoved(_devicePubKey,_accesskey);
        }
      }
      
      return true;
    }

    function getTime() constant returns(uint256){
      return block.number;
    }

    function executeFunctionLater(uint expirationTime){
            uint targetBlock = block.number + expirationTime;
            bytes4 sig = bytes4(sha3("getTime()"));
            bytes4 scheduleCallSig = bytes4(sha3("scheduleCall(bytes4,uint256)"));
            
            if(!scheduler.call.value(50000000000000000)(scheduleCallSig, sig, targetBlock))
                throw;
    }

    //kill the contract
    function killContract()
    returns (bool){
      if(msg.sender!=creator){
        return false;
      }

      suicide(creator);
      return true;
    }
}

