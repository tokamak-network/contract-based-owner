// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ITransferOwnership {
    function transferOwnership(address _owner) external;
}

contract MultiProposerableTransactionExecutor is Ownable {
    event Deposit(address indexed sender, uint amount, uint balance);
    event ProposeTransaction(
        address indexed transactionProposer,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event TransferTargetOwnership(address target, address owner);
    event AddTransactionProposer(address transactionProposer);
    event RemoveTransactionProposer(address transactionProposer);

    address[] public transactionProposers;
    mapping(address => bool) public isTransactionProposer;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;

    modifier onlyOwnerOrTransactionProposer() {
        require(
            owner() == msg.sender || isTransactionProposer[msg.sender],
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

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function addTransactionProposer(
        address _transactionProposer
    ) public onlyOwner {
        require(
            _transactionProposer != address(0) &&
                isTransactionProposer[_transactionProposer] == false &&
                owner() != _transactionProposer,
            "is already exist in transactionProposers or is the owner"
        );
        isTransactionProposer[_transactionProposer] = true;
        transactionProposers.push(_transactionProposer);

        emit AddTransactionProposer(_transactionProposer);
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

        emit RemoveTransactionProposer(_transactionProposer);
    }

    function proposeTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwnerOrTransactionProposer {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );

        emit ProposeTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function executeTransaction(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.value <= address(this).balance,
            "contract balance is not enough"
        );

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
        require(_owner != address(0), "_owner can't be 0.");

        ITransferOwnership target = ITransferOwnership(_target);

        target.transferOwnership(_owner);

        emit TransferTargetOwnership(_target, _owner);
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
        returns (address to, uint value, bytes memory data, bool executed)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed
        );
    }
}
