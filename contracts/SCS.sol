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
    uint256 foundingDate;
    uint256 originalNumberOfShares;
    uint256 currentNumberOfShares;
    uint256 requiredConfirmation;
    address[] ownerAddress;
    uint256[] stockCertificates;
    Transaction[] transactions;
  }

  struct Transaction {
    address to;
    uint256 amount;
    bool executed;
    uint256 numConfirmations;
    mapping(address => bool) isConfirmed;
  }

  mapping(string => Company) public companyList;

  modifier onlyOwner(string memory _companyName) {
    require(isOwner(_companyName), "not one of the owners");
    _;
  }

  modifier txExists(string memory _companyName, uint256 _txIndex) {
    require(isTx(_companyName, _txIndex), "tx DNE");
    _;
  }

  modifier notExecuted(string memory _companyName, uint256 _txIndex) {
    require(!hasExecuted(_companyName, _txIndex), "tx already executed");
    _;
  }

  modifier notConfirmed(string memory _companyName, uint256 _txIndex) {
    require(!hasConfirmed(_companyName, _txIndex), "tx already confirmed");
    _;
  }

  constructor(string memory _companyName, string memory _companySymbol)
    ERC721(_companyName, _companySymbol)
  {}

  function isOwner(string memory _companyName) public view returns (bool) {
    Company storage c = companyList[_companyName];
    for (uint256 i = 0; i < c.ownerAddress.length; i++) {
      if (c.ownerAddress[i] == msg.sender) return true;
    }
    return false;
  }

  function isTx(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    Company storage c = companyList[_companyName];
    if (_txIndex < c.transactions.length) return true;
    return false;
  }

  function hasExecuted(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    Company storage c = companyList[_companyName];
    if (c.transactions[_txIndex].executed) return true;
    return false;
  }

  function hasConfirmed(string memory _companyName, uint256 _txIndex)
    internal
    view
    returns (bool)
  {
    Company storage c = companyList[_companyName];
    if (c.transactions[_txIndex].isConfirmed[msg.sender]) return true;
    return false;
  }

  function submitTransaction(
    address _to,
    uint256 _amount,
    string memory _companyName
  ) public onlyOwner(_companyName) {
    Company storage c = companyList[_companyName];
    uint256 txIndex = c.transactions.length;

    c.transactions[txIndex].amount = _amount;
    c.transactions[txIndex].executed = false;
    c.transactions[txIndex].numConfirmations = 0;
    c.transactions[txIndex].to = _to;

    emit SubmitTransaction(msg.sender, _companyName, txIndex, _amount);
  }

  function confirmTransaction(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
    notConfirmed(_companyName, _txIndex)
  {
    Company storage c = companyList[_companyName];
    Transaction storage transaction = c.transactions[_txIndex];
    transaction.numConfirmations += 1;
    transaction.isConfirmed[msg.sender] = true;

    emit ConfirmTransaction(msg.sender, _companyName, _txIndex);
  }

  function executeTransaction(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
  {
    Company storage c = companyList[_companyName];
    Transaction storage transaction = c.transactions[_txIndex];

    require(
      transaction.numConfirmations >= c.requiredConfirmation,
      "cannot execute tx"
    );

    transaction.executed = true;

    emit ExecuteTransaction(msg.sender, _companyName, _txIndex);
  }

  function revokeConfirmation(string memory _companyName, uint256 _txIndex)
    public
    onlyOwner(_companyName)
    txExists(_companyName, _txIndex)
    notExecuted(_companyName, _txIndex)
  {
    Company storage c = companyList[_companyName];
    Transaction storage transaction = c.transactions[_txIndex];

    require(hasConfirmed(_companyName, _txIndex), "tx has not confirmed");

    transaction.numConfirmations -= 1;
    transaction.isConfirmed[msg.sender] = true;

    emit RevokeConfirmation(msg.sender, _companyName, _txIndex);
  }

  function createCompany(
    string memory _companyName,
    uint256 _foundingDate,
    uint256 _originalNumberOfShares,
    uint256 _requiredConfirmation,
    address[] memory _ownerAddress
  ) public {
    require(_ownerAddress.length > 0, "company needs owner");
    require(_originalNumberOfShares > 0, "need more than 0 shares");
    require(
      _requiredConfirmation > 0 &&
        _requiredConfirmation <= _ownerAddress.length,
      "need confirmation"
    );

    Company storage c = companyList[_companyName];
    c.companyName = _companyName;
    c.foundingDate = _foundingDate;
    c.originalNumberOfShares = _originalNumberOfShares;
    c.currentNumberOfShares = _originalNumberOfShares;
    c.requiredConfirmation = _requiredConfirmation;
    c.ownerAddress = _ownerAddress;
  }

  function issueStock() public {}
}
