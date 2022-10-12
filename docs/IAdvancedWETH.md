# IAdvancedWETH

*Moody Salem*

> Advanced WETH Interface

Unlocks additional features for Wrapped Ether, or WETH, that allow you to interact with contracts that     use WETH transparently as if you were using ETH. Approve this contract to spend your WETH to use.

*The underlying assumption is that the user wants to use ETH and avoid unnecessary approvals, but ERC20 is     required to interact with many protocols. This contract enables a user to interact with protocols consuming     ERC20 without additional approvals.*

## Methods

### depositAndTransferFromThenCall

```solidity
function depositAndTransferFromThenCall(uint256 amount, address to, bytes data) external payable
```

Deposits any ETH sent to the contract, and transfers additional WETH from the caller,     and then approves and calls another contract `to` with data `data`.

*Use this method to spend a combination of ETH and WETH as WETH. Refunds any unspent WETH to the caller as     ETH. Note that either `amount` or `msg.value` may be 0, but not both.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | The amount to transfer from the caller to this contract and approve for the `to` address, or 0. |
| to | address | The address to approve and call after minting WETH |
| data | bytes | The data to forward to the contract after minting WETH |

### weth

```solidity
function weth() external view returns (address payable)
```

Returns the WETH contract that this Advanced WETH contract uses.

*Returns the WETH contract that this Advanced WETH contract uses.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address payable | the WETH contract used by this contract. |

### withdrawTo

```solidity
function withdrawTo(address payable to) external nonpayable
```

Unwrap and forward all WETH held by the contract to the given address. This should never be called     directly, but rather as a callback from a contract call that results in sending WETH to this contract.

*Use this method as a callback from other contracts to unwrap WETH before forwarding to the user.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address payable | The address that should receive the unwrapped ETH. |




