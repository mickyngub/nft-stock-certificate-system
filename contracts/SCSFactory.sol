//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SCS.sol";

contract SCSFactory {
  mapping(string => address) public listCompanyAddress;

  constructor() {}

  function createCompany(
    string memory _companyName,
    string memory _companySymbol,
    uint256 _foundingDate,
    uint256 _originalNumberOfShares,
    uint256 _requiredConfirmation,
    address[] memory _ownerAddress
  ) public returns (SCS companyAddress) {
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

    // Company storage c = companyList[_companyName];
    // c.companyName = _companyName;
    // c.foundingDate = _foundingDate;
    // c.originalNumberOfShares = _originalNumberOfShares;
    // c.currentNumberOfShares = _originalNumberOfShares;
    // c.requiredConfirmation = _requiredConfirmation;
    // c.ownerAddress = _ownerAddress;
  }
}
