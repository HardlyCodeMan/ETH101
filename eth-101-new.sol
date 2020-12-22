// "SPDX-License-Identifier: AGPL-3.0"
pragma solidity 0.7.5;
// !! NOT PRODUCTION READY !! pragma experimental ABIEncoderV2; // required to allow a struct to be returned

import "./IvanOwnable-New.sol";
import "./IvanDestroyable-New.sol";

contract Ivan is IvanOwnable, Destroyable {
    
    /* 
    * Data Locations:
    * storage - most expensive, everything saved persistantly/permantly like mappings and state variables such as owner
    * memory - mid cost, only saved during a functions execution, if not saved during the function the memory data will be lost after the function has finished
    * stack - cheapest, local variables of value types such as uint
    */
    
    string public message = "Ivan Academy ETH Smart Contract Programming 101"; // Public string
    
    uint[] public numbers = [1, 2, 3]; // Public array of numbers
    
    uint public balance; // correct answer for contract balance checking assignment
    
    struct Person {
        uint id;
        string name;
        uint height;
        uint age;
        bool senior;
        address walletAddress;
    }
    
    event personCreated(string name, bool senior);
    event personDeleted(string name, bool senior, address createdBy, address deletedBy);
    event paymentReceived(uint received);
    event paymentSent(uint sent);
    event paymentTransfer(address from, address to, uint amount);

    modifier costs(uint _cost) {
        require(msg.value >= _cost, "Not enough ether sent.");
        _;
    }
    
    Person[] public people;
    
    // Mapping key => value, input the key and return the value in the format mapping(keyType=>valueType)name
    // creating mapping (address=>uint)balance
    // adding/modifying a value to a key balance[address]=10
    // accessing the value of a key balance[address]
    mapping(address => Person) private peopleMap;
    mapping(address => uint) addressBalance; // new course data
    
    address[] private creators; // Have an array store every address using the contract

    function addBalance(uint _toAdd) public onlyOwner returns(uint) {
        addressBalance[msg.sender] += _toAdd;
        return addressBalance[msg.sender];
    }
    
    function deposit() public payable returns(uint) {
        addressBalance[msg.sender] += msg.value;
        emit paymentReceived(msg.value);
        return addressBalance[msg.sender];
    }

    function getBalance() public view returns(uint) {
        return addressBalance[msg.sender];
    }
    
    function transfer(address _recipient, uint _amount) public {
        require(addressBalance[msg.sender] >= _amount, "Balance not sufficient.");
        require(msg.sender != _recipient, "cannot send to yourself.");
        
        _transfer(msg.sender, _recipient, _amount);
        
        emit paymentTransfer(msg.sender, _recipient, _amount);
    }
    
    function _transfer(address _from, address _to, uint _amount) private {
        addressBalance[_from] -= _amount;
        addressBalance[_to] += _amount;
    }
    
    function count(int _number) public pure returns(int) {
        // while loops
        int i = 0;
        while(i < 10) {
            _number++;
            i++;
        }
        
        // for loops 
        for(int j = 0; j < 10; j++) {
            _number++;
        }
        
        return _number;
    }
    
    function getMessage() public view returns(string memory) {
        return message;
    }
    
    function setMessage(string memory _newMessage) public { // requires memory for string type
        message = _newMessage;
    }
    
    // Return by array index value
    function getNumber(uint _index) public view returns(uint) {
        return numbers[_index];
    }
    
    // Now available > 0.6.0, return full arrays
    function getNumbers() public view returns(uint[] memory) {
        return numbers;
    }
    
    function setNumbers(uint _index, uint _newNumber) public {
        numbers[_index] = _newNumber;
    }
    
    function addNumber(uint _newNumber) public {
        numbers.push(_newNumber);
    }
    
    function createPerson(string memory _name, uint _height, uint _age) public payable costs(100 wei) { // requires memory for string type
        address creator = msg.sender;
        // to make the creator address payable, perhaps for refunds.
        // address payable test = address(uint160(creator));
        
        require(_age <= 150, "Age above 150, please check input.");
        require(_age >= 0, "Age less than 0, please check input.");
        
        // check payment >= needed
        //require(msg.value >= 1 ether, "Not enough ether sent to create person.");
        balance += msg.value; // correct answer for contract balance checking assignment
        
        // The long way to add a Person struct to the people array
        Person memory newPerson; // requires memory for the new Person. newPerson struct isntance will be deleted after function execution unless stored
        newPerson.id = people.length;
        newPerson.name = _name;
        newPerson.height = _height;
        newPerson.age = _age;
        if(_age >= 65) {
            newPerson.senior = true;
        }
        else {
            newPerson.senior = false;
        }
        newPerson.walletAddress = creator;
        people.push(newPerson);
        creators.push(msg.sender);
    
        // The short way to add a Person struct to the people array
        // people.push(Person(people.length, name, height, age, walletAddress));
        
        // Use the struct in a mapping, lookup via address rather then search a potentially large array
        peopleMap[creator] = newPerson;
        
        // Test to ensure the structs are the same
        // peopleMap[msg.sender] == newPerson;
        assert(
            keccak256(
                abi.encodePacked(
                    peopleMap[msg.sender].name, 
                    peopleMap[msg.sender].height, 
                    peopleMap[msg.sender].age, 
                    peopleMap[msg.sender].senior
                )
            ) == 
            keccak256(
                abi.encodePacked(
                    newPerson.name, 
                    newPerson.height, 
                    newPerson.age, 
                    newPerson.senior
                )
            )
        );
        
        // emit the personCreated event for web3 integration
        emit personCreated(newPerson.name, newPerson.senior);
        emit paymentReceived(address(this).balance);
    }
    
    //function getPerson() public view returns(Person memory) { // requires memory for string type !! RETURN of a struct type is NOT PRODUCTION READY !!
    function getPerson() public view returns(uint id, string memory name, uint height, uint age, bool senior, address walletAddress) { // requires memory for string type
        return (peopleMap[msg.sender].id, peopleMap[msg.sender].name, peopleMap[msg.sender].height, peopleMap[msg.sender].age, peopleMap[msg.sender].senior, peopleMap[msg.sender].walletAddress);
        
    }
    
    function deletePerson(address _creator) public payable onlyOwner costs(100 wei) {
        Person memory deletable = peopleMap[_creator];
        delete peopleMap[_creator];
        
        assert(peopleMap[_creator].age == 0);
        
        // emit the personDeleted event for web3 integration
        emit personDeleted(deletable.name, deletable.senior, _creator, msg.sender);
        emit paymentReceived(address(this).balance);
        
        balance += msg.value;
    }
    
    function getAddress(uint _index) public view onlyOwner returns(address) {
        return creators[_index];
    }
    
    function getCreatorsLength() public view onlyOwner returns(uint) {
        return creators.length;
    }
    
    function withdrawAll() public payable onlyOwner returns(uint) {
        uint transferValue = balance;
        balance = 0; // state changes must be done before the transfer for security
        
        msg.sender.transfer(transferValue); // On error revert
        
        /* Other method, good for custom error handling but must be done this way to prevent re-entrancy attacks
        //msg.sender.send(transferValue); // On error returns false, no revert! Requires if() statement
        if(msg.sender.send(transferValue)) {
            // success
            return transferValue;
        }
        else {
            // Failure
            balance = transferValue;
            return 0;
        }
        */
        
        emit paymentSent(transferValue);
        
        return transferValue;
    }
    
    function destroy() public onlyOwner {
        lightTheFuse();
    }
}