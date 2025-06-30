// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract MicrogridEnergyTrading {

    struct Microgrid {
        uint energyCapacity;    // Maximum energy the microgrid can supply (in kWh)
        uint energyBalance;     // Current available energy (in kWh)
        uint energyPrice;       // Price per kWh (in wei)
        bool registered;        // Whether the microgrid is registered
    }

    mapping(address => Microgrid) public microgrids;
    mapping(address => uint) public energyBalance; // Energy balance for payment purposes
    address public owner;   // Contract owner (optional, for admin tasks)

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

    // Function to register a microgrid with energy capacity and price per kWh
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

    // Function for a microgrid to list available energy for sale
    function listEnergyForSale(uint _amount) public onlyRegistered {
        require(_amount > 0, "Amount must be greater than 0");
        require(microgrids[msg.sender].energyBalance >= _amount, "Insufficient energy balance");

        microgrids[msg.sender].energyBalance -= _amount;

        emit EnergyListed(msg.sender, _amount, microgrids[msg.sender].energyPrice);
    }

    // Function for a buyer to purchase energy
    function buyEnergy(address _seller, uint _amount) public payable {
        require(microgrids[_seller].registered, "Seller not registered");
        require(microgrids[_seller].energyBalance >= _amount, "Seller does not have enough energy");
        uint totalPrice = _amount * microgrids[_seller].energyPrice;

        require(msg.value >= totalPrice, "Insufficient payment");

        // Transfer payment to seller
        payable(_seller).transfer(totalPrice);

        // Update balances
        microgrids[_seller].energyBalance -= _amount;
        energyBalance[msg.sender] += _amount;

        emit EnergyBought(msg.sender, _seller, _amount, totalPrice);
    }

    // Function for a microgrid to update their energy price
    function updateEnergyPrice(uint _newPrice) public onlyRegistered {
        require(_newPrice > 0, "Price must be greater than 0");
        microgrids[msg.sender].energyPrice = _newPrice;
    }

    // Function to withdraw funds for the contract owner
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}
