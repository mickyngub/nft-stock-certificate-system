// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SCS is ERC721Enumerable {
  event InitiateMintStock(
    address indexed owner,
    uint256 indexed txIndex,
    uint256 amount
  );
  event VoteMintStock(address indexed owner, uint256 indexed txIndex);
  event RevokeVoteMintStock(address indexed owner, uint256 indexed txIndex);
  event ExecuteMintStock(address indexed owner, uint256 indexed txIndex);

  struct StockCertificate {
    string companyName;
    address owner;
    uint256 id;
    uint256 amount;
  }

  struct Company {
    string companyName;
    string companySymbol;
    uint256 foundingDate;
    uint256 originalNumberOfShares;
    uint256 currentNumberOfShares;
    uint256 requiredConfirmation;
    address[] ownerAddress;
  }

  struct Transaction {
    address to;
    uint256 amount;
    bool executed;
    uint256 numConfirmations;
    mapping(address => bool) isConfirmed;
  }

  // mapping(address => Company) public companies;
  Company public company;
  uint256 public txId;
  mapping(uint256 => Transaction) public transaction;
  mapping(uint256 => StockCertificate) public stockCertificateId;

  modifier onlyOwner() {
    require(isOwner(msg.sender), "not one of the owners");
    _;
  }

  modifier txExists(uint256 _txIndex) {
    require(_txIndex <= txId, "transaction DNE");
    _;
  }

  modifier notExecuted(uint256 _txIndex) {
    require(!transaction[_txIndex].executed, "transaction already executed");
    _;
  }

  modifier notConfirmed(uint256 _txIndex) {
    require(
      !transaction[_txIndex].isConfirmed[msg.sender],
      "transaction already confirmed"
    );
    _;
  }

  constructor(
    string memory _companyName,
    string memory _companySymbol,
    uint256 _foundingDate,
    uint256 _originalNumberOfShares,
    uint256 _requiredConfirmation,
    address[] memory _ownerAddress
  ) ERC721(_companyName, _companySymbol) {
    company.companyName = _companyName;
    company.companySymbol = _companySymbol;
    company.foundingDate = _foundingDate;
    // both original and current are equal when the company is created
    company.originalNumberOfShares = _originalNumberOfShares;
    company.currentNumberOfShares = _originalNumberOfShares;
    company.requiredConfirmation = _requiredConfirmation;
    company.ownerAddress = _ownerAddress;
  }

  function isOwner(address sender) public view returns (bool) {
    for (uint256 i = 0; i < company.ownerAddress.length; i++) {
      if (company.ownerAddress[i] == sender) return true;
    }
    return false;
  }

  function initiateMintStock(address _to, uint256 _amount) public onlyOwner {
    txId += 1;

    transaction[txId].amount = _amount;
    transaction[txId].executed = false;
    transaction[txId].numConfirmations = 0;
    transaction[txId].to = _to;

    emit InitiateMintStock(msg.sender, txId, _amount);
  }

  function voteMintStock(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex)
  {
    transaction[_txIndex].numConfirmations += 1;
    transaction[_txIndex].isConfirmed[msg.sender] = true;

    emit VoteMintStock(msg.sender, _txIndex);
  }

  function executeMintStock(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
  {
    require(
      transaction[_txIndex].numConfirmations >= company.requiredConfirmation,
      "cannot execute transaction"
    );

    transaction[_txIndex].executed = true;

    emit ExecuteMintStock(msg.sender, _txIndex);
  }

  function revokeVoteMintStock(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
  {
    require(
      transaction[_txIndex].isConfirmed[msg.sender],
      "transaction has not confirmed"
    );

    transaction[_txIndex].numConfirmations -= 1;
    transaction[_txIndex].isConfirmed[msg.sender] = false;

    emit RevokeVoteMintStock(msg.sender, _txIndex);
  }
}
