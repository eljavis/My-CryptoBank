// Licencia 
// SPDX-License-Identifier: GPL-3.0

// Solidity version
pragma solidity 0.8.34;

// Functions:
    // 1. Deposit ether
    // 2. Withdraw ether
    // 3. Show Bank's balance
    // 4. Internal transfers
    // 5. Withdraw entire balance
    // 6. Change Admin

// Rules:
    // 1. MultiUser
    // 2. Only can deposit ether
    // 3. User can only withdraw previously deposited ether
    // 4. Max balance = Decided by owner
    // 5. MaxBalance modifiable by owner

contract CryptoBank {

    // Variables
    uint256 public maxBalance;
    address public admin;
    mapping(address => uint256) public userBalance;

    // Events
    event EtherDeposit(address user_, uint256 etheramount_);
    event EtherWithdraw(address user_, uint256 etheramount_);
    event InternalTransfer(address indexed from_, address indexed to_, uint256 amount_);
    event AdminChanged(address indexed oldAdmin_, address indexed newAdmin_);

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

    // 4. Get total contract balance
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 5. Transfer balance to another user internally
    function transferInternally(address to_, uint256 amount_) external {
        require(amount_ <= userBalance[msg.sender], "Not enough balance to transfer");
        require(to_ != address(0), "Cannot transfer to the zero address");
        require(userBalance[to_] + amount_ <= maxBalance, "Receiver would exceed max balance");

        // Update states
        userBalance[msg.sender] -= amount_;
        userBalance[to_] += amount_;

        emit InternalTransfer(msg.sender, to_, amount_);
    }

    // 6. Convenience function: Withdraw all Ether for caller
    function withdrawAll() external {
        uint256 totalAmount = userBalance[msg.sender];
        require(totalAmount > 0, "No Ether to withdraw");

        
        userBalance[msg.sender] = 0;

        
        (bool success,) = msg.sender.call{value: totalAmount}("");
        require(success, "Transfer failed");
        
        emit EtherWithdraw(msg.sender, totalAmount);
    }

    // 7. Change Admin address securely
    function changeAdmin(address newAdmin_) external onlyAdmin {
        require(newAdmin_ != address(0), "New admin cannot be the zero address");
        address oldAdmin = admin;
        admin = newAdmin_;
        
        emit AdminChanged(oldAdmin, newAdmin_);
    }
}
