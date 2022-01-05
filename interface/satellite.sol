pragma solidity ^0.8.6;

//defined interface needed to interact with other contract
interface Ibusinesslogic {
    function getAge() external pure returns (uint256);
}

pragma solidity ^0.8.6;

//satelliteV1 uses the Ibusinesslogic interface
contract satelliteV1 is Ibusinesslogic {
    function getAge() external pure override returns (uint256) {
        return 25;
    }
}

pragma solidity ^0.8.6;

//satelliteV2 uses the Ibusinesslogic interface
contract satelliteV2 is Ibusinesslogic {
    function getAge() external pure override returns (uint256) {
        return 32;
    }
}
