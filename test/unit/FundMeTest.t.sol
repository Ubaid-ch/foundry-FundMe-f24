// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    uint256 public constant SEND_VALUE=0.1 ether;
     uint256  constant STARTING_BALANCE = 10 ether;
    address alice = makeAddr("alice");
    
    
    function setUp() external{
        fundMe= new FundMe();
       

        vm.deal(alice, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);

    }
        function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);

    }
    function testFundFailsWIthoutEnoughETH() public {
    vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
    fundMe.fund();     // <- We send 0 value

    }
    function testFundUpdatesFundDataStructure() public {
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(amountFunded, SEND_VALUE);

    }

    function testAddsFunderToArrayOfFunders() public {
    
    vm.deal(alice, SEND_VALUE);
    vm.startPrank(alice);
    fundMe.fund{value: SEND_VALUE}();
    vm.stopPrank();
    address funder = fundMe.getFunder(0);
    assertEq(funder, alice);

    }

    function testOnlyOwnerCanWithdraw() public {
    vm.expectRevert();
    fundMe.withdraw();

}
modifier funded() {
    vm.prank(alice);
    vm.deal(alice, SEND_VALUE);
    fundMe.fund{value: SEND_VALUE}();
    assert(address(fundMe).balance > 0);
    _;

}
function cheaperWithdraw() public onlyOwner {
    uint256 fundersLength = s_funders.length;
    for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
        address funder = s_funders[funderIndex];
        s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);

    (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "Call failed");

}
function testWithdrawFromASingleFunder() public funded {
       // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

       
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

       
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance); 
   

    }
    
    function testWithdrawFromMultipleFundersCheaper() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        // we get hoax from stdcheats
        // prank + deal
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.cheaperWithdraw();
    vm.stopPrank();

    assert(address(fundMe).balance == 0);
    assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);

}


}