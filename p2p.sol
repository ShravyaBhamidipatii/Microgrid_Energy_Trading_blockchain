// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract MicrogridEnergyTrading {

    struct Microgrid {
        uint energyCapacity;    
        uint energyBalance;     
        uint energyPrice;       
        bool registered;        
    }

    mapping(address => Microgrid) public microgrids;
    mapping(address => uint) public energyBalance; 
    address public owner;  

    event EnergyRegistered(address indexed microgrid, uint energyCapacity, uint energyPrice);
    event EnergyListed(address indexed seller, uint amount, uint price);
    event EnergyBought(address indexed buyer, address indexed seller, uint amount, uint totalPrice);

    modifier onlyRegistered() {
        require(microgrids[msg.sender].registered, "Microgrid not registered");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }


    function registerMicrogrid(uint _energyCapacity, uint _energyPrice) public {
        require(_energyCapacity > 0, "Energy capacity must be greater than 0");
        require(_energyPrice > 0, "Energy price must be greater than 0");

        microgrids[msg.sender] = Microgrid({
            energyCapacity: _energyCapacity,
            energyBalance: _energyCapacity,
            energyPrice: _energyPrice,
            registered: true
        });

        emit EnergyRegistered(msg.sender, _energyCapacity, _energyPrice);
    }


    function listEnergyForSale(uint _amount) public onlyRegistered {
        require(_amount > 0, "Amount must be greater than 0");
        require(microgrids[msg.sender].energyBalance >= _amount, "Insufficient energy balance");

        microgrids[msg.sender].energyBalance -= _amount;

        emit EnergyListed(msg.sender, _amount, microgrids[msg.sender].energyPrice);
    }


    function buyEnergy(address _seller, uint _amount) public payable {
        require(microgrids[_seller].registered, "Seller not registered");
        require(microgrids[_seller].energyBalance >= _amount, "Seller does not have enough energy");
        uint totalPrice = _amount * microgrids[_seller].energyPrice;

        require(msg.value >= totalPrice, "Insufficient payment");


        payable(_seller).transfer(totalPrice);


        microgrids[_seller].energyBalance -= _amount;
        energyBalance[msg.sender] += _amount;

        emit EnergyBought(msg.sender, _seller, _amount, totalPrice);
    }


    function updateEnergyPrice(uint _newPrice) public onlyRegistered {
        require(_newPrice > 0, "Price must be greater than 0");
        microgrids[msg.sender].energyPrice = _newPrice;
    }


    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}
