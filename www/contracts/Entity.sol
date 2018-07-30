pragma solidity ^0.4.24;
contract Entity {
   address public owner;
   address public spvm;

   struct User {
      uint8 userType;
      uint8 instit;
      uint8 status;
   }
   
   struct Request {
       uint256 timestamp;
       address police;
       address repair;
       uint8 claimType;
       uint8 status;
       uint8 instit;
       string desc;
       uint256 payment;
   }
    
    struct Validation {
        address client;
        uint256 index;
    }
    
   /* The address of the player => the user info   
    so playerInfo[some_address].amountBet gives the amount */
    mapping(address => User) internal userInfo;
    mapping(address => Request[]) internal requests;
    mapping(address => Validation[]) public validations;
    mapping(uint8 => address) internal bank;
    mapping(uint8 => uint256) public avg;
    mapping(uint8 => uint256) public sd;

   event claimRequest(address initiator, uint256 index, address verifier);
   event payment(address initiator, uint256 amount, address receiver);

   /* Fallback function in case someone sends ether to the contract so it doesn't 
   get lost and to increase the treasury of this contract that will be distributed in each game */
    function() public payable {}
    
    function checkFund() public view returns(uint256){
        require(userInfo[msg.sender].userType == 1);
        return address(this).balance;
    }
    
    constructor() public {
        owner = msg.sender;
        userInfo[owner].userType = 1;
        userInfo[owner].instit = 1;
        bank[1] = owner;
        avg[1] = 30000;
        sd[1] = 20000;
        avg[2] = 200;
        sd[2] = 200;
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }
    
    function checkUser(address user) public view returns(bool){
        if(userInfo[user].userType != 0) return true;
        return false;
    }

    function addUser(address user, uint8 userType) public returns(bool) {
        require(userInfo[msg.sender].userType <= 2);
        if( !checkUser(user) ){
            if(userType == 2) spvm = user;
            if(userType == 3) userInfo[user].userType = 3;
            else{
                userInfo[user].userType = userType;
                userInfo[user].instit = userInfo[msg.sender].instit;
                userInfo[user].status = 2;
            }
            
            return true;
        }
        return false;
    }
    
    function openStatus(address user, uint8 status) public returns(bool){
        require(user == msg.sender || userInfo[msg.sender].userType == 2);
        if( status != 2 || status != 1 ) return false;
        else if(userInfo[msg.sender].status > 2 ) return false;
        userInfo[msg.sender].status = status;
        return true;
    }
    
   /* Permissions, msg.sender can be tweaked so future improvement */
    function getUser(address user) public view returns(uint8, uint8, uint8){
        User storage tmp = userInfo[user];
        User storage me = userInfo[msg.sender];
        if(msg.sender == user) return (tmp.userType, tmp.instit, tmp.status);
        else if(me.userType == 1 
            && tmp.instit == me.instit){
            return (tmp.userType, tmp.instit, tmp.status);
        }
        return (0, 0, 0);
    }
    
    /* Police and Repair,  Bad practice but works here */
    function getRequest(address user,uint256 index) public view returns(uint256, address, address, uint8,uint8, uint8, string, uint256){
        User storage tmp = userInfo[msg.sender];
        if(index >= requests[user].length) revert();
        Request storage req = requests[user][index];
        if(userInfo[user].status == 1 || 
            (tmp.userType== 1 && tmp.instit==userInfo[user].instit) || user==msg.sender) 
            return (req.timestamp, req.police, req.repair, req.claimType, req.status, req.instit, req.desc, req.payment);
        else if(tmp.userType == 2){
            if (req.police == msg.sender) 
                return (req.timestamp, req.police, 0, req.claimType, req.status, req.instit, req.desc, req.payment);
        }else if(tmp.userType == 3){
            if (req.repair == msg.sender) 
                return (req.timestamp,0, req.repair, req.claimType,req.status, 0, req.desc, req.payment);
        }
        return(0,0,0,0,0,0,"",0);
    }
   

    function requestClaim(address garage, uint8 claimType, uint8 status, string desc, uint256 paym) public{
        require(userInfo[msg.sender].userType > 2);
        // make sure status flag is not beyond initiation flags
        if(status > 3 || status <= 0) revert();
        else if(userInfo[garage].userType != 3 && status <= 1) revert();
        address police = spvm;
        if(status == 0 || status == 2) police = 0;
        requests[msg.sender].push(Request({
                                timestamp: now,
                                police: police,
                                repair: garage,
                                claimType: claimType,
                                status: status,
                                instit: userInfo[msg.sender].instit,
                                desc: desc,
                                payment: paym
        }));
        emit claimRequest(msg.sender, requests[msg.sender].length - 1, owner);
        if(status == 0) validations[bank[userInfo[msg.sender].instit]].push(Validation(msg.sender, requests[msg.sender].length - 1));
        if(garage != 0){
         validations[garage].push(Validation(msg.sender, requests[msg.sender].length - 1));
         emit claimRequest(msg.sender, requests[msg.sender].length - 1, garage);
        }
        if(police != 0){
         validations[spvm].push(Validation(msg.sender, requests[msg.sender].length - 1));
         emit claimRequest(msg.sender, requests[msg.sender].length - 1, spvm);
        }
    }
    
   
    /* Functions for police/repair
     0: init, 1-3: G/P/Both valid required, 4-6: GPB confirmed, 7-9: GPB denied, 10: Paid */
    function validate(uint256 index, bool answer, string expl) public{
        User storage me = userInfo[msg.sender];
        if(index >= validations[msg.sender].length) revert();
        Validation storage valid = validations[msg.sender][index];
        Request storage tmp = requests[valid.client][valid.index];
        require(me.userType > 1 && me.userType < 4);
        if(me.userType == 2){
            if(tmp.status != 1 && tmp.status != 3 && tmp.status != 5 ) revert();
            tmp.desc = concat(tmp.desc, expl);
            if(answer){
                if(tmp.status == 3){
                    tmp.status = 4;
                }else{
                    if(tmp.claimType !=0 && tmp.payment!=0 && tmp.payment < avg[tmp.claimType]){
                        valid.client.transfer(tmp.payment);
                        tmp.status = 10;
                    } else{
                        tmp.status = 6;
                        address bk = bank[tmp.instit];
                        validations[bk].push(Validation(valid.client, valid.index));
                        emit claimRequest(valid.client, index, bk);
                    }
                }
            }else{
                tmp.status = 7;
                for(uint256 i=0; i< validations[tmp.repair].length; i++){
                if(validations[tmp.repair][i].client == valid.client && validations[tmp.repair][i].index == valid.index){
                    validations[tmp.repair][i] = validations[tmp.repair][(validations[tmp.repair].length-1)];
                    validations[tmp.repair].length--;
                    break;
                }
                }
            }
            validations[msg.sender][index] = validations[msg.sender][validations[msg.sender].length-1];
            validations[msg.sender].length--;    
        }
        else if (me.userType == 3 && tmp.repair == msg.sender){
            if(tmp.status == 2 || tmp.status == 3 || tmp.status == 4 ){
                tmp.desc = concat(tmp.desc, expl);
                if(answer){
                    if(tmp.status == 3){
                        tmp.status = 5;
                    }else{
                        tmp.status = 6;
                        if(tmp.claimType !=0 && tmp.payment!=0 && tmp.payment < avg[tmp.claimType]){
                            valid.client.transfer(tmp.payment);
                            tmp.status = 10;
                        } else{
                            bk = bank[tmp.instit];
                            validations[bk].push(Validation(valid.client, valid.index)); 
                            emit claimRequest(valid.client, index, bk);
                        }
                    }               
                }else{
                    tmp.status = 8;
                    for(i=0; i< validations[tmp.police].length; i++){
                if(validations[tmp.police][i].client == valid.client && validations[tmp.police][i].index == valid.index){
                    validations[tmp.police][i] = validations[tmp.police][validations[tmp.police].length-1];
                    validations[tmp.police].length--;
                    break;
                }
            }
                }
                validations[msg.sender][index] = validations[msg.sender][validations[msg.sender].length-1];
                validations[msg.sender].length--;
            } else revert();
        }
    }
   
    function payClaim(uint256 index, bool answer, string expl) payable public{
        User storage me = userInfo[msg.sender];
        Validation storage valid = validations[msg.sender][index];
        Request storage tmp = requests[valid.client][valid.index];
        require(me.userType == 1 && me.instit==tmp.instit);
        tmp.desc = concat(tmp.desc, expl);
        if(answer){
            valid.client.transfer(msg.value);
            tmp.payment = msg.value;  
            tmp.status = 10;    
        }else{
            tmp.status = 9;
        }
        validations[msg.sender][index] = validations[msg.sender][validations[msg.sender].length-1];
        validations[msg.sender].length--;
        emit payment(msg.sender, msg.value, valid.client);
    }
    
    function setAvg(uint8 ctype, uint256 amount) public returns(bool){
        require(userInfo[msg.sender].userType == 2);
        avg[ctype] = amount;
    }
    
    function setSd(uint8 ctype, uint256 amount) public returns(bool){
        require(userInfo[msg.sender].userType == 2);
        sd[ctype] = amount;
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
