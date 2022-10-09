// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Count {
    uint256 public count;

    function increment() external {
        count++;
    }
}
