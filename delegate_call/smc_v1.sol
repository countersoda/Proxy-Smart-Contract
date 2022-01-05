pragma solidity ^0.8.6;


contract smartContractV1 {
  uint public age;

//set
    function setAge(uint newAge) external {
        age = newAge;
    }
}