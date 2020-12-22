// "SPDX-License-Identifier: AGPL-3.0"
pragma solidity 0.7.5;

import "./IvanOwnable-New.sol";

contract Destroyable is IvanOwnable {
        
    function lightTheFuse() internal onlyOwner {
        selfdestruct(msg.sender);
    }
}