// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/farm.sol";
import "forge-std/Test.sol";

contract FarmTest is Test {
    Farm f;

    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment.
    function setUp() public {
        f = new Farm(IREWARD(address(0x0)), IERC20(address(0x0)), address(this), 1e18);
    }

    function testAloc() public {
        require(f.totalAllocPoint() != 10);
        f.set(10);
        require(f.totalAllocPoint() == 10);
    }

    function testGetmult() public view{
        require(f.getMultiplier(1, 3) == 20);
        require(f.getMultiplier(3, 8) == 23);
        require(f.getMultiplier(6, 8) == 2);
    }
}
