# CandyWrapper









## Methods

### AUCTION_DROP_INTERVAL

```solidity
function AUCTION_DROP_INTERVAL() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### AUCTION_DROP_PER_STEP

```solidity
function AUCTION_DROP_PER_STEP() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### AUCTION_END_PRICE

```solidity
function AUCTION_END_PRICE() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### AUCTION_PRICE_CURVE_LENGTH

```solidity
function AUCTION_PRICE_CURVE_LENGTH() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### AUCTION_START_PRICE

```solidity
function AUCTION_START_PRICE() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### allowlist

```solidity
function allowlist(address) external view returns (uint16)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint16 | undefined |

### approve

```solidity
function approve(address to, uint256 tokenId) external payable
```



*Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred. Only a single account can be approved at a time, so approving the zero address clears previous approvals. Requirements: - The caller must own the token or be an approved operator. - `tokenId` must exist. Emits an {Approval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| tokenId | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```



*Returns the number of tokens in `owner`&#39;s account.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### devMint

```solidity
function devMint(uint256 quantity) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| quantity | uint256 | undefined |

### endAuctionAndSetupNonAuctionSaleInfo

```solidity
function endAuctionAndSetupNonAuctionSaleInfo(uint64 mintlistPriceWei, uint64 publicPriceWei, uint32 publicSaleStartTime) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| mintlistPriceWei | uint64 | undefined |
| publicPriceWei | uint64 | undefined |
| publicSaleStartTime | uint32 | undefined |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```



*Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getAuctionPrice

```solidity
function getAuctionPrice(uint256 _saleStartTime) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _saleStartTime | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getCandyAttributes

```solidity
function getCandyAttributes(uint8 control, uint16 tokenId) external view returns (string value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| control | uint8 | undefined |
| tokenId | uint16 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| value | string | undefined |

### getOwnershipData

```solidity
function getOwnershipData(uint256 tokenId) external view returns (struct IERC721A.TokenOwnership)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | IERC721A.TokenOwnership | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```



*Returns if the `operator` is allowed to manage all of the assets of `owner`. See {setApprovalForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### mint

```solidity
function mint(uint8 control, uint8 quantity) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| control | uint8 | undefined |
| quantity | uint8 | undefined |

### name

```solidity
function name() external view returns (string)
```



*Returns the token collection name.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```



*Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renderMode

```solidity
function renderMode(uint16 tokenId) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint16 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### revealCandy

```solidity
function revealCandy() external nonpayable
```






### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external payable
```



*Equivalent to `safeTransferFrom(from, to, tokenId, &#39;&#39;)`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) external payable
```



*Safely transfers `tokenId` token from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |
| _data | bytes | undefined |

### seedAllowlist

```solidity
function seedAllowlist(address[] addresses, uint16[] numSlots) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| addresses | address[] | undefined |
| numSlots | uint16[] | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*Approve or remove `operator` as an operator for the caller. Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {ApprovalForAll} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### setAuctionSaleStartTime

```solidity
function setAuctionSaleStartTime(uint32 timestamp) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| timestamp | uint32 | undefined |

### setBaseUri

```solidity
function setBaseUri(string baseUri) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| baseUri | string | undefined |

### setdaoRegistry

```solidity
function setdaoRegistry(uint16[] tokenId, uint8[] count) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint16[] | undefined |
| count | uint8[] | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified) to learn more about how these ids are created. This function call must use less than 30000 gas.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### symbol

```solidity
function symbol() external view returns (string)
```



*Returns the token collection symbol.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```



*Returns the Uniform Resource Identifier (URI) for `tokenId` token.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*Returns the total number of tokens in existence. Burned tokens will reduce the count. To get the total number of tokens minted, please see {_totalMinted}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external payable
```



*Transfers `tokenId` from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateAuthorization

```solidity
function updateAuthorization(uint16 session) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| session | uint16 | undefined |

### withdrawMoney

```solidity
function withdrawMoney(address tokenAddress) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenAddress | address | undefined |

### wrappedCandy

```solidity
function wrappedCandy(uint16 tokenId) external view returns (string)
```



*Returns an SVG string representation of the candy associated with the given tokenId. The SVG string can be used by browsers and other clients to quickly render the candy&#39;s image.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint16 | The uint16 tokenId representing the specific candy. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | A bytes containing the SVG data for the candy associated with the tokenId, in base64 format |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```



*Emitted when `owner` enables `approved` to manage the `tokenId` token.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| approved `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```



*Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### ConsecutiveTransfer

```solidity
event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to)
```



*Emitted when tokens in `fromTokenId` to `toTokenId` (inclusive) is transferred from `from` to `to`, as defined in the [ERC2309](https://eips.ethereum.org/EIPS/eip-2309) standard. See {_mintERC2309} for more details.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| fromTokenId `indexed` | uint256 | undefined |
| toTokenId  | uint256 | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```



*Emitted when `tokenId` token is transferred from `from` to `to`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |



## Errors

### ApprovalCallerNotOwnerNorApproved

```solidity
error ApprovalCallerNotOwnerNorApproved()
```

The caller must own the token or be an approved operator.




### ApprovalQueryForNonexistentToken

```solidity
error ApprovalQueryForNonexistentToken()
```

The token does not exist.




### BalanceQueryForZeroAddress

```solidity
error BalanceQueryForZeroAddress()
```

Cannot query the balance for the zero address.




### MintERC2309QuantityExceedsLimit

```solidity
error MintERC2309QuantityExceedsLimit()
```

The `quantity` minted with ERC2309 exceeds the safety limit.




### MintToZeroAddress

```solidity
error MintToZeroAddress()
```

Cannot mint to the zero address.




### MintZeroQuantity

```solidity
error MintZeroQuantity()
```

The quantity of tokens minted must be more than zero.




### OwnerQueryForNonexistentToken

```solidity
error OwnerQueryForNonexistentToken()
```

The token does not exist.




### OwnershipNotInitializedForExtraData

```solidity
error OwnershipNotInitializedForExtraData()
```

The `extraData` cannot be set on an unintialized ownership slot.




### TransferCallerNotOwnerNorApproved

```solidity
error TransferCallerNotOwnerNorApproved()
```

The caller must own the token or be an approved operator.




### TransferFromIncorrectOwner

```solidity
error TransferFromIncorrectOwner()
```

The token must be owned by `from`.




### TransferToNonERC721ReceiverImplementer

```solidity
error TransferToNonERC721ReceiverImplementer()
```

Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.




### TransferToZeroAddress

```solidity
error TransferToZeroAddress()
```

Cannot transfer to the zero address.




### URIQueryForNonexistentToken

```solidity
error URIQueryForNonexistentToken()
```

The token does not exist.





