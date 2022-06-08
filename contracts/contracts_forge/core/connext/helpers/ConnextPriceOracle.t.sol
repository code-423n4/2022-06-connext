// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "../../../utils/ForgeHelper.sol";
import {TestAggregator} from "../../../../contracts/test/TestAggregator.sol";
import {TestERC20} from "../../../../contracts/test/TestERC20.sol";
import "../../../../contracts/core/connext/helpers/ConnextPriceOracle.sol";

contract ConnextPriceOracleTest is ForgeHelper {
  // ============ Storage ============
  ConnextPriceOracle priceOracle;
  ConnextPriceOracle v1PriceOracle;
  address _aggregator;
  address _tokenA;
  address _tokenB;
  address _tokenV1 = address(1);
  address _wrapped = address(55555);

  // ============ Events ============
  event NewAdmin(address oldAdmin, address newAdmin);
  event PriceRecordUpdated(address token, address baseToken, address lpToken, bool _active);
  event DirectPriceUpdated(address token, uint256 oldPrice, uint256 newPrice);
  event AggregatorUpdated(address tokenAddress, address source);
  event V1PriceOracleUpdated(address oldAddress, address newAddress);

  // ============ Setup ============
  function setUp() public {
    utils_deployAndSetup();
  }

  // ============ utils ============
  function utils_deployAndSetup() public {
    priceOracle = new ConnextPriceOracle(_wrapped);
    v1PriceOracle = new ConnextPriceOracle(_tokenV1);
    _aggregator = address(new TestAggregator());
    _tokenA = address(new TestERC20());
    _tokenB = address(new TestERC20());

    address[] memory tokenAddresses = new address[](1);
    address[] memory sources = new address[](1);
    tokenAddresses[0] = _wrapped;
    sources[0] = _aggregator;
    v1PriceOracle.setDirectPrice(_tokenV1, 1e18);
    priceOracle.setAggregators(tokenAddresses, sources);
    priceOracle.setV1PriceOracle(address(v1PriceOracle));
  }

  // ============ getTokenPrice ============
  function test_ConnextPriceOracle_getTokenPrice_worksIfExistsInAssetPrices() public {
    priceOracle.setDirectPrice(_tokenA, 1e18);
    assertEq(priceOracle.getTokenPrice(_tokenA), 1e18);
  }

  function test_ConnextPriceOracle_getTokenPrice_worksIfAggregatorExists() public {
    assertEq(priceOracle.getTokenPrice(address(0)), 1e18);
    assertEq(priceOracle.getTokenPrice(_wrapped), 1e18);
  }

  function test_ConnextPriceOracle_getTokenPrice_worksIfDexRecordExists() public {
    address mockLpAddress = address(11111);
    TestERC20(_tokenA).mint(mockLpAddress, 100);
    TestERC20(_tokenB).mint(mockLpAddress, 200);
    priceOracle.setDirectPrice(_tokenA, 1e18);
    priceOracle.setDexPriceInfo(_tokenB, _tokenA, mockLpAddress, true);
    assertEq(priceOracle.getTokenPrice(_tokenB), 5e17);
  }

  function test_ConnextPriceOracle_getTokenPrice_worksIfv1Exists() public {
    assertEq(priceOracle.getTokenPrice(_tokenV1), 1e18);
  }

  function test_ConnextPriceOracle_getTokenPrice_fails() public {
    assertEq(priceOracle.getTokenPrice(address(12345)), 0);
  }

  // ============ getPriceFromOracle ============
  function test_ConnextPriceOracle_getPriceFromOracle_works() public {
    assertEq(priceOracle.getPriceFromOracle(_wrapped), 1e18);
  }

  // ============ getPriceFromDex ============
  function test_ConnextPriceOracle_getPriceFromDex_works() public {
    address mockLpAddress = address(11111);
    TestERC20(_tokenA).mint(mockLpAddress, 100);
    TestERC20(_tokenB).mint(mockLpAddress, 200);
    priceOracle.setDirectPrice(_tokenA, 1e18);
    priceOracle.setDexPriceInfo(_tokenB, _tokenA, mockLpAddress, true);
    assertEq(priceOracle.getPriceFromDex(_tokenB), 5e17);
  }

  function test_ConnextPriceOracle_getPriceFromDex_fails() public {
    assertEq(priceOracle.getPriceFromDex(address(12345)), 0);
  }

  // ============ getPriceFromChainlink ============
  function test_ConnextPriceOracle_getPriceFromChainlink_works() public {
    assertEq(priceOracle.getPriceFromChainlink(_wrapped), 1e18);
  }

  function test_ConnextPriceOracle_getPriceFromChainlink_fails() public {
    assertEq(priceOracle.getPriceFromChainlink(address(12345)), 0);
  }

  // ============ setDexPriceInfo ============
  function test_ConnextPriceOracle_setDexPriceInfo_failsIfNotAdmin() public {
    address mockLpAddress = address(11111);
    vm.expectRevert(bytes("caller is not the admin"));
    vm.prank(address(12345));
    priceOracle.setDexPriceInfo(_tokenB, address(12345), mockLpAddress, true);
  }

  function test_ConnextPriceOracle_setDexPriceInfo_failsIfInvalidBaseToken() public {
    address mockLpAddress = address(11111);
    vm.expectRevert(bytes("invalid base token"));
    priceOracle.setDexPriceInfo(_tokenB, address(12345), mockLpAddress, true);
  }

  function test_ConnextPriceOracle_setDexPriceInfo_worksIfOnlyAdmin() public {
    address mockLpAddress = address(11111);
    TestERC20(_tokenA).mint(mockLpAddress, 100);
    TestERC20(_tokenB).mint(mockLpAddress, 200);
    priceOracle.setDirectPrice(_tokenA, 1e18);
    vm.expectEmit(true, true, true, true);
    emit PriceRecordUpdated(_tokenB, _tokenA, mockLpAddress, true);
    priceOracle.setDexPriceInfo(_tokenB, _tokenA, mockLpAddress, true);
    assertEq(priceOracle.getPriceFromDex(_tokenB), 5e17);
  }

  // ============ setDirectPrice ============
  function test_ConnextPriceOracle_setDirectPrice_worksIfOnlyAdmin() public {
    vm.expectEmit(true, true, true, true);
    emit DirectPriceUpdated(_tokenA, 0, 2e18);
    priceOracle.setDirectPrice(_tokenA, 2e18);
    assertEq(priceOracle.assetPrices(_tokenA), 2e18);
  }

  function test_ConnextPriceOracle_setDirectPrice_failsIfNotAdmin() public {
    vm.expectRevert(bytes("caller is not the admin"));
    vm.prank(address(12345));
    priceOracle.setDirectPrice(_tokenA, 2e18);
    assertEq(priceOracle.assetPrices(_tokenA), 0);
  }

  // ============ setV1PriceOracle ============
  function test_ConnextPriceOracle_setV1PriceOracle_worksIfOnlyAdmin() public {
    ConnextPriceOracle newV1PriceOracle = new ConnextPriceOracle(_wrapped);
    vm.expectEmit(true, true, true, true);
    emit V1PriceOracleUpdated(address(v1PriceOracle), address(newV1PriceOracle));
    priceOracle.setV1PriceOracle(address(newV1PriceOracle));
  }

  function test_ConnextPriceOracle_setV1PriceOracle_failsIfNotAdmin() public {
    ConnextPriceOracle newV1PriceOracle = new ConnextPriceOracle(_wrapped);
    vm.expectRevert(bytes("caller is not the admin"));
    vm.prank(address(12345));
    priceOracle.setV1PriceOracle(address(newV1PriceOracle));
  }

  // ============ setAdmin ============
  function test_ConnextPriceOracle_setAdmin_worksIfOnlyAdmin() public {
    address newAdmin = address(333);
    vm.expectEmit(true, true, true, true);
    emit NewAdmin(address(this), newAdmin);
    priceOracle.setAdmin(newAdmin);
  }

  function test_ConnextPriceOracle_setAdmin_failsIfNotAdmin() public {
    address newAdmin = address(333);
    vm.expectRevert(bytes("caller is not the admin"));
    vm.prank(address(12345));
    priceOracle.setAdmin(newAdmin);
  }

  // ============ setAggregators ============
  function test_ConnextPriceOracle_setAggregators_worksIfOnlyAdmin() public {
    address[] memory _tokenAddresses = new address[](2);
    address _tokenAddr1 = address(11);
    address _tokenAddr2 = address(22);
    _tokenAddresses[0] = _tokenAddr1;
    _tokenAddresses[1] = _tokenAddr2;

    address[] memory _sources = new address[](2);
    address _aggregator1 = address(new TestAggregator());
    address _aggregator2 = address(new TestAggregator());
    _sources[0] = _aggregator1;
    _sources[1] = _aggregator2;
    vm.expectEmit(true, true, true, true);
    for (uint256 i = 0; i < 2; i++) {
      emit AggregatorUpdated(_tokenAddresses[i], _sources[i]);
    }
    priceOracle.setAggregators(_tokenAddresses, _sources);
  }

  function test_ConnextPriceOracle_setAggregators_failsIfNotAdmin() public {
    address[] memory _tokenAddresses = new address[](2);
    address _tokenAddr1 = address(11);
    address _tokenAddr2 = address(22);
    _tokenAddresses[0] = _tokenAddr1;
    _tokenAddresses[1] = _tokenAddr2;

    address[] memory _sources = new address[](2);
    address _aggregator1 = address(new TestAggregator());
    address _aggregator2 = address(new TestAggregator());
    _sources[0] = _aggregator1;
    _sources[1] = _aggregator2;
    vm.expectRevert(bytes("caller is not the admin"));
    vm.prank(address(12345));
    priceOracle.setAggregators(_tokenAddresses, _sources);
  }
}
