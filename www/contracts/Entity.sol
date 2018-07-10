pragma solidity ^0.4.24;
contract Entity {
   address public owner;

   struct User {
      uint8 userType;
      uint8 instit;
   }
   
   struct Request {
       address client;
       address police;
       address repair;
       uint8 status;
       uint8 instit;
       string desc;
       uint256 payment;
   }
    
    struct Validation {
        address client;
        uint256 index;
    }
    
   // The address of the player => the user info   
   // so playerInfo[some_address].amountBet gives the amount
    mapping(address => User) internal userInfo;
    mapping(address => Request[]) internal requests;
    mapping(address => Validation[]) public validations;
    mapping(uint8 => address) internal bank;

   event claimRequest(address initiator, uint256 index, address verifier);
   event payment(address initiator, uint256 amount, address receiver);

   // Fallback function in case someone sends ether to the contract so it doesn't 
   // get lost and to increase the treasury of this contract that will be distributed in each game
    function() public payable {}

    constructor() public {
        owner = msg.sender;
        userInfo[owner].userType = 1;
        userInfo[owner].instit = 1;
        bank[1] = owner;
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }
    
    function checkUser(address user) public constant returns(bool){
        if(userInfo[user].userType != 0) return true;
        return false;
    }

    function addUser(address user, uint8 userType) public returns(bool) {
        require(userInfo[msg.sender].userType == 1);
        if( !checkUser(user) ){
            userInfo[user].userType = userType;
            userInfo[user].instit = userInfo[msg.sender].instit;
            return true;
        }
        return false;
    }
    
   // Permissions, msg.sender can be tweaked so future improvement
    function getUser(address user) public view returns(uint8, uint8){
        User storage tmp = userInfo[user];
        User storage me = userInfo[msg.sender];
        if(msg.sender == user) return (tmp.userType, tmp.instit);
        else if(me.userType == 1 
            && tmp.instit == me.instit){
            return (tmp.userType, tmp.instit);
        }
        return (0, 0);
    }
   
    function getRequest(address user, uint256 index) public view //FIX
        returns(address, address, address, uint8, uint8, string, uint256){
        // Police and Repair -- Bad practice but works here
        User storage tmp = userInfo[msg.sender];
        Request storage req = requests[user][index];
        if((tmp.userType== 1 && tmp.instit==userInfo[user].instit) || user==msg.sender) 
            return (req.client, req.police, req.repair, req.status, req.instit, req.desc, req.payment);
        else if(tmp.userType == 2){
            if (req.police == msg.sender) 
                return (req.client, req.police, 0, req.status, req.instit, req.desc, req.payment);
        }else if(tmp.userType == 3){
            if (req.repair == msg.sender) 
                return (req.client,0, req.repair, req.status, 0, req.desc, req.payment);
        }
        return (0,0,0,12,0,"",0);
    }
   
   
   // Operations
   // Functions for transactions and requests
   
   // Functions for client address
    function requestClaim(address garage, uint8 status, string desc) public returns(int256){
        require(userInfo[msg.sender].userType > 2);
        // make sure status flag is not beyond initiation flags
        if(status > 3 || status <= 0) return -1;
        else if(userInfo[garage].userType != 3 && status != 1) return -1;
        requests[msg.sender].push(Request({
                                client: msg.sender,
                                police: 0,
                                repair: garage,
                                status: status,
                                instit: userInfo[msg.sender].instit,
                                desc: desc,
                                payment: 0
        }));
        emit claimRequest(msg.sender, requests[msg.sender].length - 1, owner);
        if(garage != 0){
         validations[garage].push(Validation(msg.sender, requests[msg.sender].length - 1));
         emit claimRequest(msg.sender, requests[msg.sender].length - 1, garage);
        }
        return int256(requests[msg.sender].length - 1);
    }
    
   
    // Functions for police/repair
    // 0: init, 1-3: G/P/Both valid required, 4-6: GPB confirmed, 7-9: GPB denied, 10: Paid
    function validate(uint256 index, bool answer, string expl) public returns(bool){
        User storage me = userInfo[msg.sender];
        Validation storage valid = validations[msg.sender][index];
        Request storage tmp = requests[valid.client][valid.index];
        require(me.userType > 1 && me.userType < 4);
        if(me.userType == 2){
            if(tmp.status == 1 || (tmp.status >= 3 && tmp.status <= 5) ){
                tmp.desc = concat(tmp.desc, expl);
                if(answer){
                    if(tmp.status == 3){
                        tmp.status = 4;
                    }else{
                        tmp.status = 6;
                        address bk = bank[tmp.instit];
                        validations[bk].push(Validation(valid.client, valid.index));
                        emit claimRequest(valid.client, index, bk);
                    }
                }else{
                    tmp.status = 7;
                }
                validations[msg.sender].push(Validation(msg.sender, index));
                valid = validations[msg.sender][(validations[msg.sender].length-1)];
                validations[msg.sender][(validations[msg.sender].length-1)] = Validation(0,0);
                return true;
            }
        }
        else if (me.userType == 3 && tmp.repair == msg.sender){
            if(tmp.status == 2 || (tmp.status >= 3 && tmp.status <= 5) ){
                tmp.desc = concat(tmp.desc, expl);
                if(answer){
                    if(tmp.status == 3){
                        tmp.status = 5;
                    }else{
                        tmp.status = 6;
                        bk = bank[tmp.instit];
                        validations[bk].push(Validation(valid.client, valid.index)); 
                        emit claimRequest(valid.client, index, bk);                  
                    }               
                }else{
                    tmp.status = 8;
                }
                validations[msg.sender].push(Validation(msg.sender, index));
                valid = validations[msg.sender][(validations[msg.sender].length-1)];
                validations[msg.sender][(validations[msg.sender].length-1)] = Validation(0,0);
                return true;
            }
        }
        return false;
    }
   
    function payClaim(uint256 index, bool answer, string expl) payable public{
        User storage me = userInfo[msg.sender];
        Validation storage valid = validations[msg.sender][index];
        Request storage tmp = requests[valid.client][valid.index];
        require(me.userType == 1 && me.instit==tmp.instit);
        tmp.desc = concat(tmp.desc, expl);
        if(answer){
            tmp.client.transfer(msg.value);
            tmp.payment = msg.value;  
            tmp.status = 10;    
        }else{
            tmp.status = 9;
        }
        Validation storage validEnd = validations[msg.sender][(validations[msg.sender].length-1)];
        valid = validEnd;
        validations[msg.sender][(validations[msg.sender].length-1)] = Validation(0,0);
        emit payment(msg.sender, msg.value, valid.client);
    }
    
    function concat(string _a, string _b) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory newStr = new string(_ba.length + _bb.length);
        bytes memory result = bytes(newStr);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) result[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) result[k++] = _bb[i];
        return string(result);
    }
}
