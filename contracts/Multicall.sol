//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IMulticall.sol";

contract Multicall is IMulticall {
    function aggregate(Call[] memory calls)
        public
        override
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(
                calls[i].callData
            );
            require(success, "Multicall aggregate: call failed");
            returnData[i] = ret;
        }
    }

    function blockAndAggregate(Call[] memory calls)
        public
        override
        returns (
            uint256 blockNumber,
            bytes32 blockHash,
            Result[] memory returnData
        )
    {
        (blockNumber, blockHash, returnData) = tryBlockAndAggregate(
            true,
            calls
        );
    }

    function getBlockHash(uint256 blockNumber)
        public
        view
        override
        returns (bytes32 blockHash)
    {
        blockHash = blockhash(blockNumber);
    }

    function getBlockNumber()
        public
        view
        override
        returns (uint256 blockNumber)
    {
        blockNumber = block.number;
    }

    function getCurrentBlockCoinbase()
        public
        view
        override
        returns (address coinbase)
    {
        coinbase = block.coinbase;
    }

    function getCurrentBlockDifficulty()
        public
        view
        override
        returns (uint256 difficulty)
    {
        difficulty = block.difficulty;
    }

    function getCurrentBlockGasLimit()
        public
        view
        override
        returns (uint256 gaslimit)
    {
        gaslimit = block.gaslimit;
    }

    function getCurrentBlockTimestamp()
        public
        view
        override
        returns (uint256 timestamp)
    {
        timestamp = block.timestamp;
    }

    function getEthBalance(address addr)
        public
        view
        override
        returns (uint256 balance)
    {
        balance = addr.balance;
    }

    function getLastBlockHash()
        public
        view
        override
        returns (bytes32 blockHash)
    {
        blockHash = blockhash(block.number - 1);
    }

    function tryAggregate(bool requireSuccess, Call[] memory calls)
        public
        override
        returns (Result[] memory returnData)
    {
        returnData = new Result[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(
                calls[i].callData
            );

            if (requireSuccess) {
                require(success, "Multicall aggregate: call failed");
            }

            returnData[i] = Result(success, ret);
        }
    }

    function tryBlockAndAggregate(bool requireSuccess, Call[] memory calls)
        public
        override
        returns (
            uint256 blockNumber,
            bytes32 blockHash,
            Result[] memory returnData
        )
    {
        blockNumber = block.number;
        blockHash = blockhash(block.number);
        returnData = tryAggregate(requireSuccess, calls);
    }
}
