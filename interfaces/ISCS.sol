// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/// @title Interface for Stock Certificate System
/// @dev MultiSigWallet functions and explanations are from @gnosis/MultiSigWallet

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISCS is IERC721 {
  /// @dev MultiSigWallet's event
  event Confirmation(address indexed sender, uint256 indexed transactionId);
  event Revocation(address indexed sender, uint256 indexed transactionId);
  event Submission(uint256 indexed transactionId);
  event Execution(uint256 indexed transactionId);
  event ExecutionFailure(uint256 indexed transactionId);
  event Deposit(address indexed sender, uint256 value);
  /// @dev Stock NFT ERC721's event
  event StockReissuing(uint256 amount);
  event StockIssuing(uint256 amount);

  /// @dev MultiSigWallet's functions

  function MultiSigWallet(address[] memory _owners, uint256 _required) external;

  /// @dev Allows an owner to submit and confirm a transaction.
  /// @param destination Transaction target address.
  /// @param value Transaction ether value.
  /// @param data Transaction data payload.
  /// @return transactionId.

  function submitTransaction(
    address destination,
    uint256 value,
    bytes32 data
  ) external returns (uint256 transactionId);

  /// @dev Allows an owner to confirm a transaction.
  /// @param transactionId Transaction ID.
  function confirmTransaction(uint256 transactionId) external;

  /// @dev Allows an owner to revoke a confirmation for a transaction.
  /// @param transactionId Transaction ID.
  function revokeConfirmation(uint256 transactionId) external;

  /// @dev Allows anyone to execute a confirmed transaction.
  /// @param transactionId Transaction ID.
  function executeTransaction(uint256 transactionId) external;

  /// @dev Returns the confirmation status of a transaction.
  /// @param transactionId Transaction ID.
  /// @return Confirmation status.
  function isConfirmed(uint256 transactionId) external pure returns (bool);
}
