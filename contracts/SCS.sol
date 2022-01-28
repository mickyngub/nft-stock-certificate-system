// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SCS is ERC721Enumerable {
  event SubmitTransaction(
    address indexed owner,
    string indexed companyName,
    uint256 indexed txIndex,
    uint256 amount
  );
  event ConfirmTransaction(
    address indexed owner,
    string indexed companyName,
    uint256 indexed txIndex
  );
  event RevokeConfirmation(
    address indexed owner,
    string indexed companyName,
    uint256 indexed txIndex
  );
  event ExecuteTransaction(
    address indexed owner,
    string indexed companyName,
    uint256 indexed txIndex
  );

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
  uint256 txId;
  mapping(uint256 => Transaction) public transaction;
  mapping(uint256 => StockCertificate) public stockCertificateId;

  modifier onlyOwner(string memory _companyName) {
    require(isOwner(_companyName), "not one of the owners");
    _;
  }

  modifier txExists(string memory _companyName, uint256 _txIndex) {
    require(isTx(_companyName, _txIndex), "transaction DNE");
    _;
  }

  modifier notExecuted(string memory _companyName, uint256 _txIndex) {
    require(
      !hasExecuted(_companyName, _txIndex),
      "transaction already executed"
    );
    _;
  }

  modifier notConfirmed(string memory _companyName, uint256 _txIndex) {
    require(
      !hasConfirmed(_companyName, _txIndex),
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

  function isOwner(string memory _companyName) public view returns (bool) {
    for (uint256 i = 0; i < company.ownerAddress.length; i++) {
      if (company.ownerAddress[i] == msg.sender) return true;
    }
    return false;
  }

  function isTx(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    if (_txIndex <= txId) return true;
    return false;
  }

  function hasExecuted(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    if (transaction[_txIndex].executed) return true;
    return false;
  }

  function hasConfirmed(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    if (transaction[_txIndex].isConfirmed[msg.sender]) return true;
    return false;
  }

  function submitTransaction(
    address _to,
    uint256 _amount,
    string memory _companyName
  ) public onlyOwner(_companyName) {
    txId += 1;

    transaction[txId].amount = _amount;
    transaction[txId].executed = false;
    transaction[txId].numConfirmations = 0;
    transaction[txId].to = _to;

    emit SubmitTransaction(msg.sender, _companyName, txId, _amount);
  }

  function confirmTransaction(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
    notConfirmed(_companyName, _txIndex)
  {
    transaction[_txIndex].numConfirmations += 1;
    transaction[_txIndex].isConfirmed[msg.sender] = true;

    emit ConfirmTransaction(msg.sender, _companyName, _txIndex);
  }

  function executeTransaction(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
  {
    require(
      transaction[_txIndex].numConfirmations >= company.requiredConfirmation,
      "cannot execute transaction"
    );

    transaction[_txIndex].executed = true;

    emit ExecuteTransaction(msg.sender, _companyName, _txIndex);
  }

  function revokeConfirmation(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
  {
    require(
      hasConfirmed(_companyName, _txIndex),
      "transaction has not confirmed"
    );

    transaction[_txIndex].numConfirmations -= 1;
    transaction[_txIndex].isConfirmed[msg.sender] = false;

    emit RevokeConfirmation(msg.sender, _companyName, _txIndex);
  }

  function issueStock() public {}
}
