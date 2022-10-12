# WrapperFi









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

### getPlatform

```solidity
function getPlatform() external view returns (uint8)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

### setPlatform

```solidity
function setPlatform(uint8 config) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| config | uint8 | undefined |

### unwrap

```solidity
function unwrap() external payable
```






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

### wrap

```solidity
function wrap() external payable
```









