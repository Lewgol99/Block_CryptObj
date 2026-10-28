// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogAnchor {
    address public immutable owner = msg.sender;      // only the deploying wallet may write
    mapping(bytes32 => uint64) private next;          // ledgerId => next expected entry index

    event Anchored(bytes32 indexed ledgerId, uint64 indexed firstIndex, uint32 count, bytes32 head, bytes32[] hashes);

    function nextIndex(bytes32 ledgerId) public view returns (uint64) {
        uint64 n = next[ledgerId];
        return n == 0 ? 1 : n;                        // a new ledger starts at entry 1
    }

    function anchor(bytes32 ledgerId, uint64 firstIndex, bytes32[] calldata hashes) external {
        require(msg.sender == owner, "not owner");
        require(hashes.length > 0, "empty");
        require(firstIndex == nextIndex(ledgerId), "bad index");   // no gaps, no repeats
        next[ledgerId] = firstIndex + uint64(hashes.length);
        emit Anchored(ledgerId, firstIndex, uint32(hashes.length), hashes[hashes.length - 1], hashes);
    }
}
