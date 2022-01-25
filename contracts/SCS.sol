// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MultiSigWallet.sol";

contract SCS is ERC721Enumerable {
  using Strings for uint256;
  MultiSigWallet public mSig;
  uint256 public immutable foundingDate;
  uint256 public immutable originalNumberOfShares;
  uint256 public numberOfShares;

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
  }
}
