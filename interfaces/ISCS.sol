// SPDX-License-Identifier: MIT

// MultiSigWallet functions and explanations are from @gnosis/MultiSigWallet
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISCS is IERC721 {
  event Confirmation(address indexed sender, uint256 indexed transactionId);
  event Revocation(address indexed sender, uint256 indexed transactionId);
  event Submission(uint256 indexed transactionId);
  event Execution(uint256 indexed transactionId);
  event ExecutionFailure(uint256 indexed transactionId);
  event Deposit(address indexed sender, uint256 value);

  event StockReissuing(uint256 amount);
  event StockIssuing(uint256 amount);

  function MultiSigWallet(address[] _owners, uint256 _required) public;

  function submitTransaction(
    address destination,
    uint256 value,
    bytes32 data
  ) public returns (uint256 transactionId);

  function confirmTransaction(uint256 transactionId) public;

  function revokeConfirmation(uint256 transactionId) public;

  function executeTransaction(uint256 transactionId) public;

  function isConfirmed(uint256 transactionId) public pure returns (bool);

  function addTransaction(
    address destination,
    uint256 value,
    bytes32 data
  ) internal returns (uint256 transactionId);

  function getConfirmationCount(uint256 transactionId)
    public
    pure
    returns (uint256 count);

  function getTransactionCount(bool pending, bool executed)
    public
    pure
    returns (uint256 count);
}
