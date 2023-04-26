// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OracleAggregator is Ownable{

    struct TokenInfo {
     uint8 decimals;
     bool dataSigned;
     address callAddress;
     bytes callData;
    }
 
    mapping(address => TokenInfo) internal tokensInfo;

    constructor() public {
        
    }

    function setTokenOracle(address token, address callAddress, uint8 decimals, bytes calldata callData, bool signed) external onlyOwner{
        require(callAddress != address(0),"OracleAggregator:: call address can not be zero");
        require(token != address(0),"OracleAggregator:: token address can not be zero");
        tokensInfo[token].callAddress = callAddress;
        tokensInfo[token].decimals = decimals;
        tokensInfo[token].callData = callData;
        tokensInfo[token].dataSigned = signed;
    }

    function getTokenOracleDecimals(address token) external view returns(uint8 _tokenOracleDecimals){
        _tokenOracleDecimals = tokensInfo[token].decimals;
    }

    function getTokenPrice(address token) external view returns (uint tokenPriceUnadjusted){
        tokenPriceUnadjusted =  _getTokenPrice(token);
    }

    function _getTokenPrice(address token) internal view returns (uint tokenPriceUnadjusted){
        (bool success, bytes memory ret) = tokensInfo[token].callAddress.staticcall(tokensInfo[token].callData);
        if (tokensInfo[token].dataSigned){
            tokenPriceUnadjusted = uint(abi.decode(ret,(int)));
        }
        else{
            tokenPriceUnadjusted = abi.decode(ret,(uint));
        }
    }


}