// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;
/// @title WrapperFi
/// @author 0xEVM1
/// @notice A vending machine for wrapped native tokens. In this example for Ethereum Mainnet, in goes Ether,
///     outcomes Wrapped Ether. Base level infrastructure for Wrapper Fi site and suite of DAO supportable services.

/*

                                                  ██████
                                                  ██░░░░██
                                                ██░░    ░░██
                                                ██░░  ░░░░░░██
                                      ████████████░░░░░░░░░░░░██
                                    ██░░░░░░░░░░░░██░░░░░░░░░░██
                                  ██░░░░      ░░░░░░██░░░░░░████
                                ██░░░░          ░░░░░░██████
                                ██░░          ░░  ░░░░██
                                ██░░   WRAPPER FI ░░░░██
                                ██░░               ░░░██
                                ██░░░░░░░░░░░░░░░░░░░░██
                            ██████░░░░░░░░░░░░░░░░░░░░██
                        ████░░░░░░██░░░░░░░░░░░░░░░░██
                        ██░░    ░░░░██░░░░░░░░░░░░██
                        ██░░  ░░░░░░░░████████████
                          ██░░░░░░░░░░██
                            ██░░░░░░░░██
                              ██░░░░██
                                ██████

*/

import "./interfaces/IWETH9.sol";
import "./interfaces/IAdvancedWETH.sol";

contract WrapperFi is IAdvancedWETH {
    address payable public override immutable weth;
    address payable internal platformProvision;
    uint8 private basis;

    uint8 constant MAX_BASIS = 101;

    constructor(address payable _weth, uint8 config) {
        weth = _weth;
        basis = config;
        platformProvision = payable(msg.sender);
    }

    function wrap() payable external {
        uint256 amount = msg.value;
        uint256 platform = amount / 10000 * basis;
        uint256 balance = amount - platform;

        if (msg.value > 0) {
            IWETH9(weth).deposit{value: balance}();
        }

        if (amount > 0) {
            IWETH9(weth).transferFrom(msg.sender, address(this), balance);
        }
        platformProvision.transfer(platform);

    }

    function unwrap() payable external {
        uint wethBalance = IWETH9(weth).balanceOf(address(this));

        if (wethBalance > 0) {
            uint256 amount = wethBalance;
            uint256 platform = amount / 10000 * basis;
            uint256 balance = amount - platform;
            IWETH9(weth).withdraw(balance);
            IWETH9(weth).withdraw(platform);
        }
    }

    function setPlatform(uint8 config) external {
        require(config < MAX_BASIS, "Max 100 basis points");
        basis = config;
    }

    function getPlatform() public view returns (uint8) {
        return basis;
    }

    // See interface for documentation.
    function depositAndTransferFromThenCall(uint amount, address to, bytes calldata data) external override payable {
        uint256 platform = amount / 10000 * basis;
        uint256 balance = amount - platform;

        if (msg.value > 0) {
            IWETH9(weth).deposit{value: balance}();
        }
        if (amount > 0) {
            IWETH9(weth).transferFrom(msg.sender, address(this), balance);
        }
        uint total = msg.value + amount;
        require(total >= msg.value, 'OVERFLOW'); // nobody should be this rich.
        require(total > 0, 'ZERO_INPUTS');
        IWETH9(weth).approve(to, total);
        (bool success,) = to.call(data);
        require(success, 'TO_CALL_FAILED');
        // unwrap and refund any unspent WETH.
        withdrawTo(payable(msg.sender));
    }

    // Only the WETH contract may send ETH via a call to withdraw.
    receive() payable external { require(msg.sender == weth, 'WETH_ONLY'); }

    // See interface for documentation.
    function withdrawTo(address payable to) public override {
        uint wethBalance = IWETH9(weth).balanceOf(address(this));
        if (wethBalance > 0) {
            IWETH9(weth).withdraw(wethBalance);
            (bool success,) = to.call{value: wethBalance}('');
            require(success, 'WITHDRAW_TO_CALL_FAILED');
        }
    }
}
