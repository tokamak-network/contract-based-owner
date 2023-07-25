// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITransferOwnership {
    function transferOwnership(address _owner) external;
}

contract MultiProposerableTransactionExecutor {
    event Deposit(address indexed sender, uint amount, uint balance);
    event ProposeTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address public owner;
    mapping(address => bool) public isOwner;

    address[] public transactionProposers;
    mapping(address => bool) public isTransactionProposer;

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

    modifier onlyOwnerOrTransactionProposer() {
        require(
            isOwner[msg.sender] || isTransactionProposer[msg.sender],
            "not owner or not transactionProposer"
        );
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

    function addTransactionProposer(
        address _transactionProposer
    ) public onlyOwner {
        require(
            isTransactionProposer[_transactionProposer] == false &&
                isOwner[_transactionProposer] == false,
            "is already exist in transactionProposers or is the owner"
        );
        isTransactionProposer[_transactionProposer] = true;
        transactionProposers.push(_transactionProposer);
    }

    function removeTransactionProposer(
        address _transactionProposer
    ) public onlyOwner {
        require(
            isTransactionProposer[_transactionProposer] == true,
            "is not exist in transactionProposers"
        );
        isTransactionProposer[_transactionProposer] = false;

        for (uint i = 0; i < transactionProposers.length - 1; i++) {
            if (transactionProposers[i] == _transactionProposer) {
                transactionProposers[i] = transactionProposers[
                    transactionProposers.length - 1
                ];
                break;
            }
        }
        transactionProposers.pop();
    }

    function setOwner(address _owner) public onlyOwner {
        require(
            isTransactionProposer[_owner] == false && isOwner[_owner] == false,
            "is already exist in transactionProposers or is the owner"
        );

        isOwner[owner] = false;
        isOwner[_owner] = true;
        owner = _owner;
    }

    function proposeTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwnerOrTransactionProposer {
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

        emit ProposeTransaction(msg.sender, txIndex, _to, _value, _data);
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

    function transferTargetOwnership(
        address _target,
        address _owner
    ) public onlyOwner {
        ITransferOwnership target = ITransferOwnership(_target);

        target.transferOwnership(_owner);
    }

    function getTransactionProposers() public view returns (address[] memory) {
        return transactionProposers;
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
