# Multiple ways to upgrade a Solidity smart contract

## 1. Proxy Pattern

Users interact with proxy address. Proxy delegates calls to business logic contract.
This method separates stored data (proxy contract) and business logic (separate contract).

![Proxy](img/proxy.webp)

```
User ---- tx ---> Proxy ----------> Implementation_v0
                     |
                     |--------------> Implementation_v1
                     |
                     |--------------> Implementation_v2
```

### How contract functions are called

Ethereum transactions contain a field called data. This field is optional and must be empty when sending ethers, but, when interacting with a contract, it must contain something. It contains call data, which is information required to call a specific contract function. This information includes:

- Function identifier, which is defined as the first 4 bytes of hashed function signature, e.g.: `keccak256("transfer(address,uint256)")`
- Function arguments that follow function identifier and are encoded according to the ABI specification.

Every smart contract compiled by Solidity has a branching logic that parses call data and decides which function to call depending on function identifier extracted from call data.

#### => Problem: _storage collisions_

When the logic contract writes to `_owner`, it does so in the scope of the proxy’s state, and in reality writes to `_implementation`

| Proxy                    | Implementation     |                         |
| ------------------------ | ------------------ | ----------------------- |
| address \_implementation | address \_owner    | <=== Storage collision! |
| ...                      | mapping \_balances |                         |
|                          | uint256 \_supply   |                         |
|                          | ...                |                         |

#### => Solution: _Unstructured Storage Proxies_

Instead of storing the `_implementation` address at the proxy’s first storage slot, it chooses a pseudo random slot instead.
Other proxy implementations that face this problem usually imply having the proxy know about the logic contract’s storage structure and adapt to it, or instead having the logic contract know about the proxy’s storage structure and adapt to it. This is why this approach is called "unstructured storage"; neither of the contracts needs to care about the structure of the other.

Example from OpenZeppelin can be found [here](https://github.com/OpenZeppelin/openzeppelin-labs/tree/master/upgradeability_using_unstructured_storage) <br>
An example of how the randomized storage is achieved, following EIP 1967:

```java
bytes32 private constant implementationPosition = bytes32(uint256( keccak256('eip1967.proxy.implementation')) - 1 ));
```

Since __constant state variables__ do not occupy storage slots, there’s no concern of the `implementationPosition` being accidentally overwritten by the logic contract. Due to how Solidity lays out its state variables in storage there is extremely little chance of collision of this storage slot being used by something else defined in the logic contract.

### Storage Collisions Between Implementation Versions

Storage collisions between different versions of the logic contract can occur.

Incorrect storage preservation:

| Implementation_v0 | Implementation_v1       |                         |
| ----------------- | ----------------------- | ----------------------- |
| address owner     | address lastContributor | <=== Storage collision! |
| mapping balances  | address owner           |                         |
| uint256 supply    | mapping balances        |                         |
| ...               | uint256 supply          |                         |
|                   | ...                     |                         |

Correct storage preservation:

| Implementation_v0 | Implementation_v1       |                         |
| ----------------- | ----------------------- | ----------------------- |
| address owner     | address owner           |                         |
| mapping balances  | mapping balances        |                         |
| uint256 supply    | uint256 supply          |                         |
| ...               | address lastContributor | <=== Storage extension. |
|                   | ...                     |                         |

It is up to the user to have new versions of a logic contract extend previous versions, or otherwise guarantee that the storage hierarchy is always appended to but not modified.

### The Constructor Caveat

A constructor is only called once when deployed, hence a proxy contract cannot call the constructor of the logic contract.
Instead, in the logic contract, move code from constructor to regular 'initializer' function.

This is why when we create a proxy using OpenZeppelin Upgrades, you can provide the name of the initializer function and pass parameters.

To ensure that the initialize function can only be called once, a simple modifier is used. OpenZeppelin Upgrades provides this functionality via a contract that can be extended:

```javascript
// contracts/MyContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyContract is Initializable {
    function initialize(
        address arg1,
        uint256 arg2,
        bytes memory arg3
    ) public payable initializer {
        // "constructor" code...
    }
}
```

Notice how the contract extends Initializable and implements the initializer provided by it.

Clashing can also happen among functions with different names. Every function that is part of a contract’s public ABI is identified, at the bytecode level, by a 4-byte identifier. This identifier depends on the name and arity of the function, but since it’s only 4 bytes, there is a possibility that two different functions with different names may end up having the same identifier. The Solidity compiler tracks when this happens within the same contract, but not when the collision happens across different ones, such as between a proxy and its logic contract.

## 2. Interface Pattern

Interfaces are used to abstract contract logic.
Main contract might update the address of the satellite contract.

## 3. Store all data in storage contract

Data is stored in a seperate smart contract. Smart contracts with business logic configure their access with the storage contract.

Links:<br>
https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies?utm_source=zos&utm_medium=blog&utm_campaign=proxy-pattern<br>
https://eips.ethereum.org/EIPS/eip-1967<br>
https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html<br>
https://medium.com/coinmonks/upgradeable-proxy-contract-from-scratch-3e5f7ad0b741<br>

In-Depth:<br>
https://blog.openzeppelin.com/proxy-patterns/<br>
https://fravoll.github.io/solidity-patterns/proxy_delegate.html

More:<br>
https://github.com/fravoll/solidity-patterns<br>
https://fravoll.github.io/solidity-patterns/eternal_storage.html
