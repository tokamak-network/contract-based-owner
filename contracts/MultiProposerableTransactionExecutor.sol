// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiProposerableTransactionExecutor {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address public owner;
    mapping(address => bool) public isOwner;

    address[] public proposers;
    mapping(address => bool) public isProposer;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier onlyProposer() {
        require(isProposer[msg.sender], "not owner");
        _;
    }

    modifier onlyOwnerOrProposer() {
        require(isOwner[msg.sender] || isProposer[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    constructor(address _owner) {
        isOwner[_owner] = true;
        owner = _owner;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function addProposer(address _proposer) public onlyOwner {
        require(
            isProposer[_proposer] == false && isOwner[_proposer] == false,
            "is already exist in proposers or is the owner"
        );
        isProposer[_proposer] = true;
        proposers.push(_proposer);
    }

    function removeProposer(address _proposer) public onlyOwner {
        require(isProposer[_proposer] == true, "is not exist in proposers");
        isProposer[_proposer] = false;

        for (uint i = 0; i < proposers.length - 1; i++) {
            if (proposers[i] == _proposer) {
                proposers[i] = proposers[proposers.length - 1];
                break;
            }
        }
        proposers.pop();
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[owner] = false;
        isOwner[_owner] = true;
        owner = _owner;
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwnerOrProposer {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function executeTransaction(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function getProposers() public view returns (address[] memory) {
        return proposers;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(
        uint _txIndex
    )
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
