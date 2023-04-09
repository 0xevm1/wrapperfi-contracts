// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/******************************************************************************************

                                                  ██████
                                                  ██░░░░██
                                                ██░░    ░░██
                                                ██░░  ░░░░░░██
                                      ████████████░░░░░░░░░░░░██
                                    ██░░░░░░░░░░░░██░░░░░░░░░░██
                                  ██░░░░      ░░░░░░██░░░░░░████
                                ██░░░░          ░░░░░░██████
                                ██░░          ░░  ░░░░██
                                ██░░  WRAPPER FI  ░░░░██
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

TODO:
Dutch Auction minting contract

Consider getter and setter functions for things you want control over

Make deployment javascript with randomvalues to pass in

Background is a gradient for colors, maybe need map

ok - Make unrevealed state

Make whitelist and dutch auction (like Azuki did it)

Could have candy name in text, with the other description being smaller, since its always the same

******************************************************************************************/

contract CandyWrapper is ERC721A {

    /** only used to limit the minting function **/
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier callerHasTokenID(uint16 tokenId) {
        require(msg.sender == ownerOf(tokenId), "Not the owner");
        _;
    }

    bytes private candyBytes;

    //st0 is background
    //st1 is wrapper ends
    //st2 is highlights
    //st3 is wrapper body
    //st4 is stripes
    //st5 is wrapper outer body
    struct Candy {
        mapping(uint8 => string[2]) attributeBackground;
        string[10] attributeWrapperEnds;
        string[10] attributeWrapperHighlights;
        string[10] attributeWrapperBody;
        string[10] attributeWrapperStripes;
        string[10] attributeWrapperOuterBody;
        string descriptorA;
        string descriptorB;
        string descriptorC;
        uint16 AUTHORIZATION;
        bool reveal; //default false
    }

    Candy private candyCollection;

    struct Vending {
        uint32 auctionSaleStartTime;
        uint32 publicSaleStartTime;
        uint64 mintlistPrice;
        uint64 publicPrice;
        uint64 modePrice;
        uint32 publicSaleKey;
    }

    Vending private vendingMachine;

    /** when owning an NFT, the owner can set it to be a raster image hosted offchain, resets for the next owner **/
    // Store tokenId => owner relationship
    mapping(uint16 => address) public tokenIdToOwner;

    // Store owner => tokenIds relationship

    mapping(address => uint16[]) public rasterMap;
    mapping(address => mapping(uint16 => uint256)) private ownerTokenIdToIndex;

    /** end relational ownership for offchain switch **/

    mapping(address => uint256) public allowlist;

    mapping(uint16 => uint16) public daoRegistryCount; //not initialized

    constructor(bytes memory attributes) ERC721A("Candy", "CANDY"){
        assembly {
            let image := or(shl(16, shl(6, 1)), 0xC350)
            mstore(0x40, image)
        }
        let key = uint256(keccak256(abi.encodePacked(uint256(0x40)))) - 1;

        //define attributes
        mapping(uint8 => string[2]) memory attrBg;
                                attrBg[0] = ["#0b2d13", "#79c98c"]; //dark color, light color
                                attrBg[1] = ["#682850", "#FFCAEB"];
                                attrBg[2] = ["#303470", "#CCCFFF"];
                                attrBg[3] = ["#306a5f", "#CCFFF5"];
                                attrBg[4] = ["#2f692f", "#CCFFCC"];
                                attrBg[5] = ["#67692f", "#FDFFCF"];
                                attrBg[6] = ["#692f2f", "#FFCFCF"];
                                attrBg[7] = ["#2f6930", "#8AFF8D"];
                                attrBg[8] = ["#2f6169", "#8AEEFF"];
                                attrBg[9] = ["#5f2f69", "#EB8AFF"];

        /* bright contrasting colors */
        string[10] memory attrWrapperEnds = ["#8086ff","#ff80e6","#80ffc8","#8cff80","#f5ff80",
                                             "#f64444","#f444f6","#f6a044","#449cf6","#f644b1"];

        /* corresponds to background base color, a lighter version of it as if reflecting */
        string[10] memory attrWrapperHighlights = ["#fcdef1", "#e6e8fe", "#ffffff", "#ffffff", "#ffffff",
                                                   "#ffffff", "#c8ffc9", "#ffffff", "#f8d8ff", "#ffffff"];

        string[10] memory attrWrapperBody = ["#fe7c84", "#e77cfe", "#7c82fe", "#7cfeea", "#7cfe7c",
                                             "#e7fe7c", "#fecc7c", "#d49b68", "#65d46d", "#ff00f6"];
        /* vibrant colors */
        string[10] memory attrWrapperStripes = ["#e70095", "#007bff", "#d0001a", "#5ecf00", "#00e4b6",
                                                "#00cfff", "#ff00ff", "#fff759", "#00ffff", "#b567eb"];

        /* compliments body color */
        string[10] memory attrWrapperOutline = ["#9c8b8c", "#ac9090", "#8c8d9e", "#919f9d", "#9ca99c",
                                                "#aeb19e", "#a19e98", "#a9a39e", "#879388", "#a294a2"];

        //descriptors
        string[10] memory descriptorA = [
        "Sugary",
        "Chewy",
        "Colorful",
        "Flavorful",
        "Delicious",
        "Tasty",
        "Sweet smelling",
        "Gummy",
        "Sticky",
        "Soft",
        "Mouth watering"
        ];

        string[10] memory descriptorB = [
        "Irresistible",
        "Satisfying",
        "Aromatic",
        "Scrumptious",
        "Delightful",
        "Oozing",
        "Juicy",
        "Addictive",
        "Fluffy",
        "Rich"
        ];

        string[10] memory descriptorC = [
        "Sweets",
        "Treats",
        "Candies",
        "Gumdrops",
        "Suckers",
        "Jawbreakers",
        "Rock candy",
        "Gummies",
        "Chews",
        "Jellies"
        ];


        //persist possible attributes
        candyCollection = Candy(
                            attrBg,
                            attrWrapperEnds,
                            attrWrapperHighlights,
                            attrWrapperBody,
                            attrWrapperStripes,
                            attrWrapperOutline,
                            descriptorA,
                            descriptorB,
                            descriptorC,
                            key & 0xffffffff, //AUTHORIZATION variable
                            false //not revealed state yet
                          );

        //set passed in attributes for the whole collection
        createCandyWrappers(attributes);
    }

    /**
     * @dev Calculates the index for a new token ID based on the next available ID.
     * The index is determined by generating a random hash from the previous token ID and then
     * taking the modulo of 10 to ensure that it falls within the range of possible indices.
     * We use this for understanding getting random colors and attributes from the chosen index of the attribute arrays, for that specific tokenID()
     * @return The index for the new token ID.
     */
    function indexFromTokenID(uint16 memory value) private view returns (uint) {
        uint randomHash = uint(keccak256(value));
        return randomHash % 10;
    }

    // this should accept a string of indices. each set of attributes takes 3 bytes each, and
    function createCandyWrappers(bytes memory attributes) internal {
        candyBytes = attributes;
    }

    //unpack indices. three pairs of indices (6 indices) fit in 3 bytes
    function unpackAttributes(uint256 memory startIndex) internal returns (bytes1[6] memory) {
        require(startIndex + 3 <= candyBytes.length, "Index out of bounds");

        bytes1[3] memory attr;
        for (uint256 i = 0; i < 3; i++) {
            attr[i] = candyBytes[startIndex + i];
        }

        bytes1[] memory candyFeatures = new bytes1[](6);
        candyFeatures[0] = binaryRightShift(attr[0], 4);
        candyFeatures[1] = getLastN(attr[0], 4);
        candyFeatures[2] = binaryRightShift(attr[1], 4);
        candyFeatures[3] = getLastN(attr[1], 4);
        candyFeatures[4] = binaryRightShift(attr[2], 4);
        candyFeatures[5] = getLastN(attr[2], 4);

        return candyFeatures;
    }
    /*** bit shifting methods ***/
    function binaryLeftShift(bytes1 a, uint8 n) internal pure returns (bytes1) {
        return a << n;
    }

    function binaryRightShift(bytes1 a, uint8 n) internal pure returns (bytes1){
        return a >> n;
    }

    function getLastN(bytes1 x, uint8 n) internal pure returns (bytes1) {
        uint8 y = uint8(x);

        uint256 mask = (1 << n) - 1;

        uint8 z = y & uint8(mask);

        return bytes1(z);
    }

    function bytesToBinaryString(bytes1 b) internal pure returns (string memory) {
        bytes memory result = new bytes(8);
        for (uint8 i = 0; i < 8; i++) {
            result[i] = (b & (2 ** (7 - i))) != 0 ? "1" : "0";
        }
        return string(result);
    }

    /*** end bit shifting methods ***/

    /*function seedAllowlist(address[] memory addresses, uint256[] memory numSlots)
    external
    onlyOwner
    {
        require(
            addresses.length == numSlots.length,
            "addresses does not match numSlots length"
        );
        for (uint256 i = 0; i < addresses.length; i++) {
            allowlist[addresses[i]] = numSlots[i];
        }
    }

    function allowlistMint() external payable callerIsUser {
        uint256 price = uint256(saleConfig.mintlistPrice);
        require(price != 0, "allowlist sale has not begun yet");
        require(allowlist[msg.sender] > 0, "not eligible for allowlist mint");
        require(totalSupply() + 1 <= collectionSize, "reached max supply");
        allowlist[msg.sender]--;
        _safeMint(msg.sender, 1);
        refundIfOver(price);
    }*/


    function mint(uint256 quantity) external payable callerIsUser {

        SaleConfig memory config = saleConfig;
        uint256 publicSaleKey = uint256(config.publicSaleKey);
        uint256 publicPrice = uint256(config.publicPrice);
        uint256 publicSaleStartTime = uint256(config.publicSaleStartTime);
        require(
            publicSaleKey == callerPublicSaleKey,
            "called with incorrect public sale key"
        );

        require(
            isPublicSaleOn(publicPrice, publicSaleKey, publicSaleStartTime),
            "public sale has not begun yet"
        );

        require(
            totalSupply() + quantity <= candyCollection.AUTHORIZATION,
            "Too much Candy."
        );

        require(
            numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint,
            "Can not mint this many"
        );

        _mint(msg.sender, quantity);
        refundIfOver(publicPrice * quantity);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

    function reveal() external onlyOwner {
        require(candyCollection.reveal == false, "Reveal event already occurred");
        candyCollection.reveal = true;
    }

    /*** rescue functions ***/

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function withdrawERC20Token(address tokenAddress) external onlyOwner nonReentrant {
        // Create an instance of the ERC20 token using the provided token address
        IERC20 token = IERC20(tokenAddress);

        // Check the contract's balance of the specified token
        uint256 contractTokenBalance = token.balanceOf(address(this));

        // Ensure the contract has enough balance to fulfill the withdrawal request
        require(contractTokenBalance >= 0, "Not enough tokens in the contract");

        // Transfer the specified amount of tokens to the caller (msg.sender)
        token.transfer(msg.sender, contractTokenBalance);
    }

    function updateAuthorization(uint16 session) external onlyOwner nonReentrant {
        candyCollection.AUTHORIZATION += session;
    }

    /*** end rescue functions ***/

    /*** attribute functions to publicly and programmatically retrieve attributes, for outside and community applications
    * //st0 is background
    * //st1 is wrapper ends
    * //st2 is highlights
    * //st3 is wrapper body
    * //st4 is stripes
    * //st5 is wrapper outer body
    *
    * redundant things are declared, but the user needs to be able to pass in a tokenId independently, which would be
    * easier to acquire and find than a random index. they can simulate random indexes by sending in different tokenIds
    ***/

    function getBackground(uint16 tokenId) public view returns(string[2] memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeBackground(uint8(candyFeatures[0])); //needs to be a gradient or return two values
    }

    function getWrapperEnds(uint16 tokenId) public view returns(string memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeWrapperEnds(uint8(candyFeatures[1]));
    }

    function getWrapperHighlights(uint16 tokenId) public view returns(string memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeWrapperHighlights(uint8(candyFeatures[2]));
    }

    function getWrapperBody(uint16 tokenId) public view returns(string memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeWrapperBody(uint8(candyFeatures[3]));
    }

    function getWrapperStripes(uint16 tokenId) public view returns(string memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeWrapperStripes(uint8(candyFeatures[4]));
    }

    function getWrapperOuterBody(uint16 tokenId) public view returns(string memory value){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);
        return candyCollection.attributeWrapperOuterBody(uint8(candyFeatures[5]));
    }

    function getDescription(uint16 tokenId) public view returns(string memory value) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        let memory index = indexFromTokenID(tokenId);

        //can do even and odd variations here to add variation
        return candyCollection.descriptorA[index] + " " +
               candyCollection.descriptorB[tokenId % 2 ? index : indexFromTokenID(index)] + " " + //else condition is a derivative, for entropy
               candyCollection.descriptorC[index];
    }

    /*** end attribute functions ***/

    /*
        Some platforms do not support SVG, this method allows switching to a raster image

    */
    function modePrice(uint256 price) external onlyOwner {
        vendingMachine.modePrice = price;
    }

    /*
        offchain mode, usable for displaying on other PFP platforms that don't support SVGs
    */
    function rasterMode(uint16 tokenId) external payable callerIsUser callerHasTokenID(tokenId) nonReentrant {
        //add to rasterMap
        rasterMap[msg.sender].push(tokenId);
        ownerTokenIdToIndex[msg.sender][tokenId] = rasterMap[msg.sender].length - 1;
        refundIfOver(vendingMachine.modePrice);
    }

    /*
        onchain mode
    */
    function vectorMode(uint16 tokenId) external payable callerIsUser callerHasTokenID(tokenId) nonReentrant {
        //remove from rasterMap

        uint256 indexToRemove = ownerTokenIdToIndex[msg.sender][tokenId];
        uint16 lastTokenId = ownerToTokenIds[msg.sender][ownerToTokenIds[msg.sender].length - 1];

        ownerToTokenIds[msg.sender][indexToRemove] = lastTokenId;
        ownerTokenIdToIndex[msg.sender][lastTokenId] = indexToRemove;
        ownerToTokenIds[msg.sender].pop();

        delete ownerTokenIdToIndex[msg.sender][tokenId];

        refundIfOver(vendingMachine.modePrice);
    }

    function wrappedCandy(uint16 tokenId) public view returns(string memory){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        //st0 is background
        //st1 is wrapper ends
        //st2 is highlights
        //st3 is wrapper body
        //st4 is stripes
        //st5 is wrapper outer body

        //6 bytes of attribute indices
        bytes1[6] memory candyFeatures = unpackAttributes(tokenId * 3);

        bytes memory svg = abi.encodePacked(
            '<svg version="1.1" id="Layer_1" transform="rotate(-90)" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 800 800" style="enable-background:new 0 0 800 800;" xml:space="preserve">',
            '<style type="text/css">',
            '.st0{fill:', candyCollection.reveal ? candyCollection.attributeBackground[uint8(candyFeatures[0])] : '#FFFFFF',';}',
            '.st1{fill:', candyCollection.reveal ? candyCollection.attributeWrapperEnds[uint8(candyFeatures[1])]:'#000000',';}',
            '.st2{fill:', candyCollection.reveal ? candyCollection.attributeWrapperHighlights[uint8(candyFeatures[2])]:'#FFFFFF',';}',
            '.st3{fill:', candyCollection.reveal ? candyCollection.attributeWrapperBody[uint8(candyFeatures[3])]:'#000000',';}',
            '.st4{fill:', candyCollection.reveal ? candyCollection.attributeWrapperStripes[uint8(candyFeatures[4])]:'#000000',';}',
            '.st5{opacity:0.5;fill:', candyCollection.reveal ? candyCollection.attributeWrapperOuterBody[uint8(candyFeatures[5])]:'#000000',';enable-background:new    ;}',
            '</style>', //white ? question mark for unrevealed tokens, hide hover layer
            '<rect class="st0" width="800" height="800"/>',
            '<path class="st1" d="M94.6,635c0,0-26.7-4.9-42.1-14.8s-33-26-30.9-30.9c2.1-4.9,21.7-9.8,61.1-28.1s92.7-49.2,127.8-48.4 s52.7,14.1,52.7,14.1s62.4,37.8,56.6,109.4c-4.7,58.1-24.1,84.1-41.1,115.9c-7.1,13.3-7.8,29.7-14.9,31.1c-7,1.4-18.4-6.9-26-13.4 c-12.8-10.9-20.5-34.1-36.9-43.3s-41.4-9.2-62.3-24.1C100,674.9,94.6,635,94.6,635z"/>',
            '<path class="st2" d="M82,593.2c-0.6,5.7,14.6,13.4,25.3,12.2s27.8-10.3,49.8-20.7c26-12.2,62.4-21.4,59.7-32.9 c-2.7-11.5-38.6-2.3-66.2,7.6C123,569.5,82.8,586,82,593.2z M215.6,618.6c-4.5-9.3-24.9-5-49.8,2.3s-36.7,11.9-39.4,26 c-2.7,13.8,5.4,23.3,15.7,30.6s22.6,12.6,29.4,12.3c6.9-0.4,11.5-2.3,15.7-12.6c2.5-6.2,5.5-15.6,11.5-24.9 C205.6,641.6,220.6,629,215.6,618.6L215.6,618.6z M228.1,732.5c0,10,13,26.8,22.6,23.8c10.8-3.4,10.1-26.7,15.7-54.3 c8.8-43.6,18.9-70.2,6.1-74.2c-8.4-2.7-22.6,32.5-29.9,53.9C237.3,697.7,228.1,720.3,228.1,732.5L228.1,732.5z"/>',
            '<path class="st1" d="M506.8,290.1c32.3,30.3,78.2,46.1,132.8,16.2c42.6-23.3,57.6-54.1,87.9-73c30.3-18.9,48.8-16.7,48.4-21.6 c-0.4-4.8-15.8-20.2-32.6-28.1c-16.7-7.9-31.7-4.8-41.3-12.8c-9.6-7.9-11-34.3-29.4-49.7c-18.4-15.4-33.9-13.2-48.4-27.2 s-18.9-34.7-35.2-48.8s-36.9-26.8-41.8-23.8s-2.2,14.1-11.9,46.6c-9.7,32.6-51.9,98.1-55.4,146.9 C477.6,249.2,485.8,270.3,506.8,290.1z"/>',
            '<path class="st2" d="M517.9,240c8.9,5.1,20-45.4,37.5-73c17.5-27.6,34.1-42.9,34.1-53.4S574.2,76,563.3,78.2s-10.6,19.9-12.9,27.6 c-2.7,8.7-20.8,46.6-26.6,59.7C515.3,184.4,503.6,231.9,517.9,240L517.9,240z M558.3,242.7c5.8,5.1,21.7-9.7,49.3-35.6 c30-28.1,40.2-41.4,28.1-53.7c-11.1-11.1-24.2-1.9-41.3,20.8C581.8,190.9,551.5,236.7,558.3,242.7z M606.3,252.4 c2.9,8.1,42.8-7.7,59.9-13.1c17.2-5.3,38.7-15.5,38.7-26.1s-13.1-20.8-26.4-19.1c-13.3,1.7-36.7,23.8-44,29.8 C624.1,232.4,604.3,247.1,606.3,252.4L606.3,252.4z"/>',
            '<path class="st3" d="M276.6,556.6c42,40.4,84.9,53.9,143.6,49.4c75.4-5.9,171-88.2,168.8-187.3c-1.8-80-41.9-125.6-71.1-146.3 c-26.9-19.1-68.6-45.6-132-38.9c-76.1,8-167.2,87.2-167.8,182.8C217.6,492.7,244.4,525.5,276.6,556.6z"/>',
            '<path class="st4" d="M334,545.8c60.6,27.6,80.3,60.6,80.3,60.6s12.4-0.6,23.8-3.1c13.4-2.9,24.1-7.6,24.1-7.6s-26.1-35.3-63.9-57.1 c-41.1-23.6-75.8-38.8-106.8-44.7s-63.9-8.6-63.9-8.6s3.2,10.4,9.8,22.9c5.2,9.9,9.3,14.9,9.3,14.9S283.5,522.7,334,545.8L334,545.8 z M219.2,442.5c0,0,25.6-4.7,74.4,7.3c23.6,5.8,54.6,15.4,88.9,31.5c30.7,14.4,52.7,28.3,70.9,40.4c42.8,28.3,54.9,47.8,54.9,47.8 s8.8-6.3,15.8-12.8c7-6.4,14.6-14.8,14.6-14.8s-18.1-33.1-96.6-76.9s-127.6-55.6-161.2-60.3c-33.6-4.8-61.8-4-61.8-4 s-1,11.2-0.9,20.8C218.1,433.5,219.2,442.5,219.2,442.5L219.2,442.5z M230.2,357c0,0,99.1,2.8,185.6,46.7 c80.5,40.8,148.6,103.8,148.6,103.8s5.7-8.8,10.8-20.4c5.8-13.2,8.4-24.6,8.4-24.6s-13.1-14.3-43.4-35.5 c-25.5-17.8-61.6-43.4-113.7-66.3c-42.6-18.7-75-26.7-102.6-33.1c-44.1-10.2-72.6-8.6-72.6-8.6s-5.6,6.9-11.7,18.4 C233.5,348.5,230.2,357,230.2,357L230.2,357z M286.1,280.3c0,0,67.4,2.4,165.2,45.8c37.9,16.8,62.1,31.5,82.9,45.8 c38.3,26.3,54.8,46.9,54.8,46.9s-0.6-17.4-2.8-31.2c-2.4-15.3-6.4-27.3-6.4-27.3s-35.5-34.8-108.6-67.9 c-70.1-31.8-139.7-42.4-139.7-42.4s-11,4.7-23.9,13.6C297.8,270.3,286.1,280.3,286.1,280.3L286.1,280.3z"/>',
            '<path class="st2" d="M258.5,452.8c7.4,34,31.3,68.4,52.9,77.1c21.9,8.8,32.8-6.3,28.2-21.2c-4.6-14.9-26.2-35.1-31.9-67.3 s-2.6-59.5,1.1-73c3.7-13.5,2.6-24.6-7.8-27.4c-9.9-2.7-23.2,2.7-34.8,25.4C253.5,391.4,253.1,427.8,258.5,452.8L258.5,452.8z"/>',
            '<path class="st5" d="M386,233.4c-76.1,8-167.2,87.2-167.8,182.8c-0.5,76.4,26.3,109.3,58.6,140.4c42,40.4,84.9,53.9,143.6,49.4 c75.4-5.9,171-88.2,168.8-187.3c-1.8-80-41.9-125.6-71.1-146.3C491.1,253.2,449.4,226.7,386,233.4L386,233.4z M502.4,293 c25.3,18,60,57.4,61.5,126.6c1.9,85.8-80.8,156.9-146.1,162.1c-50.8,4-87.9-7.7-124.2-42.7c-27.9-26.9-51.1-55.3-50.6-121.4 c0.5-82.7,79.4-151.3,145.2-158.2C443.1,253.6,479.1,276.5,502.4,293L502.4,293z"/>',
            '</svg>'
    );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    //on PFPMode, use super
    function tokenURI(uint16 tokenId) override public view returns (string memory){
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        //st0 is background
        //st1 is wrapper ends
        //st2 is highlights
        //st3 is wrapper body
        //st4 is stripes
        //st5 is wrapper outer body

        //unpack indices. three pairs of indices (6 indices) fit in 3 bytes
        //6 bytes of attribute indices
        bytes1[6] memory candyFeatures = unpackAttributes(id * 3);

        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "🍬', tokenId.toString(), ' ', getDescription(), '",',
            '"description": "Candy",',
            '"image": "', wrappedCandy(tokenId), '"',
            '"attributes": [',
                '{',
                    '"trait_type": "Name"',
                    '"value": "', getDescription(), '"'
                '},',
                '{',
                    '"trait_type": "Background"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeBackground[uint8(candyFeatures[0])] : "#FFFFFF", '"'
                '},',
                '{',
                    '"trait_type": "Twist Ties"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeWrapperEnds[uint8(candyFeatures[1])] : "#000000", '"'
                '},'
                '{',
                    '"trait_type": "Accent"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeWrapperHighlights[uint8(candyFeatures[2])] : "#000000", '"'
                '},'
                '{',
                    '"trait_type": "Body"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeWrapperBody[uint8(candyFeatures[3])] : "#000000", '"'
                '},'
                '{',
                    '"trait_type": "Stripes"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeWrapperStripes[uint8(candyFeatures[4])] : "#000000", '"'
                '},'
                '{',
                    '"trait_type": "Outline"',
                    '"value": "', candyCollection.reveal ? candyCollection.attributeWrapperOuterBody[uint8(candyFeatures[5])] : "#000000", '"'
                '},'
                '{',
                    '"trait_type": "DAOs Registered"',
                    '"value": "', candyCollection.daoRegistryCount[tokenId], '"'
                '},'

        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}
