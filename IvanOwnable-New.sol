// "SPDX-License-Identifier: AGPL-3.0"
pragma solidity 0.7.5;

contract IvanOwnable {
        
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Function not initiated by contract owner.");
        _; // If true, continue execution
    }
    
    constructor() {
        owner = msg.sender;
    }
}