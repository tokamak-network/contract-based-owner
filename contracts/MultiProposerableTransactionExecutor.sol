// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ITransferOwnership {
    function transferOwnership(address _owner) external;
}

contract MultiProposerableTransactionExecutor is Ownable {
    event ProposeTransaction(
        address indexed transactionProposer,
        uint256 indexed txIndex,
        address indexed to,
        bytes data
    );
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransactionFailed(
        address indexed owner,
        uint256 indexed txIndex
    );
    event TransferTargetOwnership(address target, address owner);
    event AddTransactionProposer(address transactionProposer);
    event RemoveTransactionProposer(address transactionProposer);

    address[] public transactionProposers;
    mapping(address => bool) public isTransactionProposer;

    struct Transaction {
        address to;
        bytes data;
        bool executed;
        bool failed;
    }

    Transaction[] public transactions;

    function addTransactionProposer(
        address _transactionProposer
    ) external onlyOwner {
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
    ) external onlyOwner {
        require(
            isTransactionProposer[_transactionProposer] == true,
            "is not exist in transactionProposers"
        );
        isTransactionProposer[_transactionProposer] = false;

        for (uint256 i = 0; i < transactionProposers.length - 1; i++) {
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

    function proposeTransaction(address _to, bytes memory _data) external {
        require(
            owner() == msg.sender || isTransactionProposer[msg.sender],
            "not owner or not transactionProposer"
        );

        require(_to != address(0), "_to can't be zero address");
        require(_data.length != 0, "_data must be exist");

        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({to: _to, data: _data, executed: false, failed: false})
        );

        emit ProposeTransaction(msg.sender, txIndex, _to, _data);
    }

    function executeTransaction(uint256 _txIndex) external onlyOwner {
        require(_txIndex < transactions.length, "tx does not exist");
        require(!transactions[_txIndex].executed, "tx already executed");

        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;

        (bool success, ) = transaction.to.call(transaction.data);
        if (!success) {
            transaction.failed = true;
            emit ExecuteTransactionFailed(msg.sender, _txIndex);
        }

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function transferTargetOwnership(
        address _target,
        address _owner
    ) external onlyOwner {
        require(_owner != address(0), "_owner can't be 0");

        ITransferOwnership target = ITransferOwnership(_target);

        target.transferOwnership(_owner);

        emit TransferTargetOwnership(_target, _owner);
    }

    function getTransactionProposers()
        external
        view
        returns (address[] memory)
    {
        return transactionProposers;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 _txIndex
    )
        external
        view
        returns (address to, bytes memory data, bool executed, bool failed)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.data,
            transaction.executed,
            transaction.failed
        );
    }
}
