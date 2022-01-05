pragma solidity ^0.8.6;

//in the upgraded contract you need to keep all existing state variables in the same order
//add new state variables below existing state variables or you will overwrite data 

contract smartContractV2 {
  uint public age1;
  uint public age2;

//set
    function setAge1(uint newAge1) external {
        age1 = newAge1;
    }

//set
    function setAge2(uint newAge2) external {
        age2 = newAge2;  
    }
}