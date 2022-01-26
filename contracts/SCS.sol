// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MultiSigWallet.sol";

contract SCS is ERC1155Supply, ERC1155Burnable {
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
  }

  MultiSigWallet public mSig;

  constructor(
    string memory _companyName,
    string memory _companySymbol,
    address[] memory _owners,
    uint256 _foundingDate,
    uint256 _originalNumberOfShares
  ) ERC721(_companyName, _companySymbol) {
    mSig = new MultiSigWallet(_owners, _owners.length);
    foundingDate = _foundingDate;
    originalNumberOfShares = _originalNumberOfShares;
    _safeMint(mSig, _originalNumberOfShares);
  }
}
