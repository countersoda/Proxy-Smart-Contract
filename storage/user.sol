pragma solidity ^0.8.6;

import "./storage.sol";

//logic is in the UserContract and data storage is in the UserStorage contract
//if we want to upgrade the usercontract we can and will not loose any data

contract UserContract {
    UserStorage userStorage;

    //set the address of the storage contract that this contract should user
    //all functions will read and write data to this contract
    function setStorageContract(address _userStorageAddress) public {
        userStorage = UserStorage(_userStorageAddress);
    }

    //reads the addressSet map in the UserStorage contract
    function isMyUserNameRegistered() public view returns (bool) {
        return userStorage.getAddressSet(msg.sender);
    }

    //writes to the addressSet map in the UserStorage contract
    function registerMe() public {
        userStorage.setAddressSet(msg.sender, true);
    }

    //set the age in the storage contract
    function setAge(uint256 newAge) public {
        userStorage.setAge(newAge);
    }

    //get the age in the storage contract
    function getAge() public view returns (uint256) {
        return userStorage.getAge();
    }
}
