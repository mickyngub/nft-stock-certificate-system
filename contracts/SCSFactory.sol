//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SCS.sol";

contract SCSFactory {
  SCS public scs;

  mapping(string => address) public listCompanyAddress;

  constructor() {}

  modifier companyNotExists(string memory _companyName) {
    require(
      listCompanyAddress[_companyName] == address(0),
      "company already exists"
    );
    _;
  }

  function createCompany(
    string memory _companyName,
    string memory _companySymbol,
    uint256 _foundingDate,
    uint256 _originalNumberOfShares,
    uint256 _requiredConfirmation,
    address[] memory _ownerAddress
  ) public companyNotExists(_companyName) returns (SCS companyAddress) {
    require(_ownerAddress.length > 0, "company needs owner");
    require(_originalNumberOfShares > 0, "need more than 0 shares");
    require(
      _requiredConfirmation > 0 &&
        _requiredConfirmation <= _ownerAddress.length,
      "need confirmation"
    );

    companyAddress = new SCS(
      _companyName,
      _companySymbol,
      _foundingDate,
      _originalNumberOfShares,
      _requiredConfirmation,
      _ownerAddress
    );

    listCompanyAddress[_companyName] = address(companyAddress);
  }

  function getCompanyInfo(string memory _companyName)
    public
    returns (
      string memory,
      string memory,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    address companyAddress = listCompanyAddress[_companyName];
    scs = SCS(companyAddress);
    (
      string memory companyName,
      string memory companySymbol,
      uint256 foundingDate,
      uint256 originalNumberOfShares,
      uint256 currentNumberOfShares,
      uint256 requiredConfirmation
    ) = scs.company();
    return (
      companyName,
      companySymbol,
      foundingDate,
      originalNumberOfShares,
      currentNumberOfShares,
      requiredConfirmation
    );
  }
}
