// SPDX-License-Identifier: MIT

/// @note MultiSigWallet taken from https://solidity-by-example.org/app/multi-sig-wallet/

pragma solidity ^0.8.10;

contract MultiSigWallet {
  event Deposit(address indexed sender, uint256 amount, uint256 balance);
  event SubmitTransaction(
    address indexed owner,
    uint256 indexed txIndex,
    uint256 amount
  );
  event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
  event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
  event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

  address[] public owners;
  mapping(address => bool) public isOwner;
  uint256 public numConfirmationsRequired;

  struct Transaction {
    address to;
    uint256 value;
    bytes32 data;
    bool executed;
    uint256 numConfirmations;
  }

  mapping(uint256 => mapping(address => bool)) public isConfirmed;

  Transaction[] public transactions;

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not one of the owners");
    _;
  }

  modifier txExists(uint256 _txIndex) {
    require(_txIndex < transactions.length, "tx DNE");
    _;
  }

  modifier notExecuted(uint256 _txIndex) {
    require(!transactions[_txIndex].executed, "tx already executed");
    _;
  }

  modifier notConfirmed(uint256 _txIndex) {
    require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
    _;
  }

  constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
    require(_owners.length > 0, "owners required");
    require(
      _numConfirmationsRequired > 0 &&
        _numConfirmationsRequired <= _owners.length,
      "invalid number of required confirmations"
    );
    for (uint256 i = 0; i < _owners.length; i++) {
      address owner = _owners[i];

      require(owner != address(0), "invalid owner");
      require(!isOwner[owner], "owner not unique");

      isOwner[owner] = true;
      owners.push(owner);
    }
    numConfirmationsRequired = _numConfirmationsRequired;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }

  function submitTransaction(
    address _to,
    uint256 _value,
    bytes32 _data
  ) public onlyOwner {
    uint256 txIndex = transactions.length;

    transactions.push(
      Transaction({
        to: _to,
        value: _value,
        data: _data,
        executed: false,
        numConfirmations: 0
      })
    );

    //   emit SubmitTransaction(msg.sender, txIndex, amount);
  }

  function confirmTransaction(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex)
  {
    Transaction storage transaction = transactions[_txIndex];
    transaction.numConfirmations += 1;
    isConfirmed[_txIndex][msg.sender] = true;

    emit ConfirmTransaction(msg.sender, _txIndex);
  }

  function executeTransaction(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
  {
    Transaction storage transaction = transactions[_txIndex];

    require(
      transaction.numConfirmations >= numConfirmationsRequired,
      "cannot execute tx"
    );

    transaction.executed = true;

    emit ExecuteTransaction(msg.sender, _txIndex);
  }

  function revokeConfirmation(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
  {
    Transaction storage transaction = transactions[_txIndex];

    require(isConfirmed[_txIndex][msg.sender], "tx has not confirmed");

    transaction.numConfirmations -= 1;
    isConfirmed[_txIndex][msg.sender] = false;

    emit RevokeConfirmation(msg.sender, _txIndex);
  }
}
