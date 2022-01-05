pragma solidity ^0.8.6;

//this contract is used to store data

contract UserStorage {
    //a mapping to determine which contract has access to write data to this contract
    //used in the modifier below
    mapping(address => bool) accessAllowed;
    uint256 private age;

    //a basic mapping that allows one to set an address and a bool value
    //for example - is this address registered on the platform?
    mapping(address => bool) addressSet;

    //function modifier checks to see if an address has permission to update data
    //bool has to be true
    modifier isAllowed() {
        require(accessAllowed[msg.sender] == true);
        _;
    }

    //access is allowed to the person that deployed the contract
    function UserStorageAccess() public {
        accessAllowed[msg.sender] = true;
    }

    //set an address to the accessAllowed map and set bool to true
    //uses the isAllowed function modifier to determine if user can change data
    //this function controls which addresses can write data to the contract
    //if you update the UserContract you would add the new address here
    function allowAccess(address _address) public isAllowed {
        accessAllowed[_address] = true;
    }

    //set an address to the accessAllowed map and set bool to false
    //uses the isAllowed function modifier to determine if user can change data
    //this function controls which addresses need to have thier write access removed from the contract
    //if you update the UserContract you would set the old contract address to false
    function denyAccess(address _address) public isAllowed {
        accessAllowed[_address] = false;
    }

    //gets an address from the addressSet map and displays true or false
    function getAddressSet(address _address) public view returns (bool) {
        return addressSet[_address];
    }

    //sets an address to the addressSet map and sets the bool true or false
    //uses the isAllowed function modifier to determine if user can change data
    function setAddressSet(address _address, bool _bool) public isAllowed {
        addressSet[_address] = _bool;
    }

    //get the age from the age variable
    function getAge() public view returns (uint256) {
        return age;
    }

    //set an age to the age variable
    //uses the isAllowed function modifier to determine if user can change data
    function setAge(uint256 newAge) public isAllowed {
        age = newAge;
    }
}
