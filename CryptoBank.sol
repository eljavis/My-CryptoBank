// Licencia 
// SPDX-License-Identifier: GPL-3.0

// Solidity version
pragma solidity 0.8.24;

// Functions:
    // 1. Deposit ether
    // 2. Withdraw ether

// Rules:
    // 1. MultiUser
    // 2. Only can deposit ether
    // 3. User can only withdraw previously deposited ether
    // 4. Max balance = 5 ether
    // 5. MaxBalance modifiable by owner
    // UserA -> Deposit (5 ether)
    // UserB -> Deposit (2 ether) 
    // Bank balance = 7 ether
    // UserA -> Deposit(1 ether) -> deposit(5 ether) -> withdraw(2 ether) -> deposit(5 ether)

contract CryptoBank {

    // Variables
    uint256 public maxBalance;
    address public admin;
    mapping(address => uint256) public userBalance;

    // Events
    event EtherDeposit(address user_, uint256 etheramount_);
    event EtherWithdraw(address user_, uint256 etheramount_);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not allowed");
        _;
    }

    constructor(uint256 maxBalance_, address admin_) {
        maxBalance = maxBalance_;
        admin = admin_;
    }

    // External Functions

    // 1. Deposit
    function depositEther() external payable {
        require(userBalance[msg.sender] + msg.value <= maxBalance, "MaxBalance reached");
        userBalance[msg.sender] += msg.value; // userBalance[msg.sender] = userBalance[msg.sender] + msg.value; 
        emit EtherDeposit(msg.sender, msg.value);               
    }

    // 2. Withdraw
    function withdrawEther(uint256 amount_) external {
        require(amount_ <= userBalance[msg.sender], "Not enough ether");
                                                                                // CEI pattern: 1. Checks 2. Effects 3. Interaction
                                                                                // Reentrancy attacks
                 
        // 1. Update state
        userBalance[msg.sender] -= amount_;
                                                                      
        // 2. Transfer ether
        (bool success,) = msg.sender.call{value: amount_}(""); // RECEIVE
        require(success, "Transfer failed");

        emit EtherWithdraw(msg.sender, amount_);
    }

    // 3. Modify maxBalance
    function modifyMaxBalance(uint256 newMaxBalance_) external onlyAdmin {
        maxBalance = newMaxBalance_;
    }
}