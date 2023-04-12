// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

Make whitelist and dutch auction (like Azuki did it)

Dev mint
Foundation mint


******************************************************************************************/

contract CandyWrapper is ERC721A, Ownable {

    /** only used to limit the minting function **/
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Candy is for people.");
        _;
    }

    modifier callerHasTokenId(uint16 tokenId) {
        require(msg.sender == ownerOf(tokenId), "Not your candy.");
        _;
    }

    /*was modifier but this increased contract size*/
    function idCheck(uint16 tokenId) private view {
        require(_exists(tokenId), "No Candy.");
    }

    //st0 is background
    //st1 is wrapper ends
    //st2 is highlights
    //st3 is wrapper body
    //st4 is stripes
    //st5 is wrapper outer body
    struct Candy {
        uint16 AUTHORIZATION;
        bool reveal; //default false
        uint8 maxPerAddressDuringMint;
        uint32 auctionSaleStartTime;
        uint32 publicSaleStartTime;
        uint64 mintlistPrice;
        uint64 publicPrice;
        uint32 publicSaleKey;
        uint64 modePrice;
        string baseTokenURI; //metadata URI
        uint24[10] attributeWrapperEnds;
        uint24[10] attributeWrapperHighlights;
        uint24[10] attributeWrapperBody;
        uint24[10] attributeWrapperStripes;
        uint24[10] attributeWrapperOuterBody;
        string[10] descriptorA;
        string[10] descriptorB;
        string[10] descriptorC;
        mapping(uint8 => uint24[2]) attributeBackground;
        mapping(address => uint16) allowlist;
        mapping(uint16 => uint8) daoRegistryCount; //referrals system
        mapping(uint16 => bool) uriMode;
    }

    Candy private candyCollection;

    function setdaoRegistry(uint16[] calldata tokenId, uint8[] calldata count) external onlyOwner {
        require(tokenId.length == count.length, "Same length necessary.");

        for (uint i = 0; i < tokenId.length; i++) {
            candyCollection.daoRegistryCount[tokenId[i]] = count[i];
        }
    }

    constructor() ERC721A("Candy", "CANDY"){
        assembly {
            let part1 := shl(16, 1)
            let part2 := 0xC350
            let image := or(part1, part2)
        }
        uint256 key = uint256(keccak256(abi.encodePacked(uint256(0x40)))) - 1;

        /***
            configure dutch auction here, hardcode configurations

            add these to struct, set them in constructor, no getters just make client side follow the same rules
            uint256 public constant AUCTION_START_PRICE = 1 ether;
            uint256 public constant AUCTION_END_PRICE = 0.15 ether;
            uint256 public constant AUCTION_PRICE_CURVE_LENGTH = 340 minutes;
            uint256 public constant AUCTION_DROP_INTERVAL = 20 minutes;
            uint256 public constant AUCTION_DROP_PER_STEP =
            (AUCTION_START_PRICE - AUCTION_END_PRICE) /
            (AUCTION_PRICE_CURVE_LENGTH / AUCTION_DROP_INTERVAL);

            configure allowlist here, the whitelist, pass into constructor no setter

            configure baseURI here, no setter


        ***/

        candyCollection.AUTHORIZATION = uint16(key & 0xffffffff); //AUTHORIZATION variable
        candyCollection.reveal = false;

        //define attributes
        candyCollection.attributeBackground[0] = [0x0b2d13, 0x79c98c]; //dark color, light color
        candyCollection.attributeBackground[1] = [0x682850, 0xFFCAEB];
        candyCollection.attributeBackground[2] = [0x303470, 0xCCCFFF];
        candyCollection.attributeBackground[3] = [0x306a5f, 0xCCFFF5];
        candyCollection.attributeBackground[4] = [0x2f692f, 0xCCFFCC];
        candyCollection.attributeBackground[5] = [0x67692f, 0xFDFFCF];
        candyCollection.attributeBackground[6] = [0x692f2f, 0xFFCFCF];
        candyCollection.attributeBackground[7] = [0x2f6930, 0x8AFF8D];
        candyCollection.attributeBackground[8] = [0x2f6169, 0x8AEEFF];
        candyCollection.attributeBackground[9] = [0x5f2f69, 0xEB8AFF];

        // bright contrasting colors
        candyCollection.attributeWrapperEnds = [0x8086ff,0xff80e6,0x80ffc8,0x8cff80,0xf5ff80,
                                                0xf64444,0xf444f6,0xf6a044,0x449cf6,0xf644b1];


        // corresponds to background base color, a lighter version of it as if reflecting
        candyCollection.attributeWrapperHighlights = [0xfcdef1, 0xe6e8fe, 0xffffff, 0xffffff, 0xffffff,
                                                      0xffffff, 0xc8ffc9, 0xffffff, 0xf8d8ff, 0xffffff];

        candyCollection.attributeWrapperBody = [0xfe7c84, 0xe77cfe, 0x7c82fe, 0x7cfeea, 0x7cfe7c,
                                                0xe7fe7c, 0xfecc7c, 0xd49b68, 0x65d46d, 0xff00f6];
        // vibrant colors
        candyCollection.attributeWrapperStripes =  [0xe70095, 0x007bff, 0xd0001a, 0x5ecf00, 0x00e4b6,
                                                    0x00cfff, 0xff00ff, 0xfff759, 0x00ffff, 0xb567eb];

        // compliments body color
        candyCollection.attributeWrapperOuterBody = [0x9c8b8c, 0xac9090, 0x8c8d9e, 0x919f9d, 0x9ca99c,
                                                     0xaeb19e, 0xa19e98, 0xa9a39e, 0x879388, 0xa294a2];

        //descriptors
        candyCollection.descriptorA = ["Sugary",
                                       "Chewy",
                                       "Colorful",
                                       "Flavorful",
                                       "Delicious",
                                       "Tasty",
                                       "Sweet smelling",
                                       "Gummy",
                                       "Sticky",
                                       "Soft"];

        candyCollection.descriptorB = ["Irresistible",
                                        "Satisfying",
                                        "Aromatic",
                                        "Scrumptious",
                                        "Delightful",
                                        "Oozing",
                                        "Juicy",
                                        "Addictive",
                                        "Fluffy",
                                        "Rich"];

        candyCollection.descriptorC = ["Sweets",
                                        "Treats",
                                        "Candies",
                                        "Gumdrops",
                                        "Suckers",
                                        "Jawbreakers",
                                        "Rock candy",
                                        "Gummies",
                                        "Chews",
                                        "Jellies"];
    }

    function bytesToBinaryString(bytes1[6] memory b) internal pure returns (string[6] memory) {
        string[6] memory fill;

        for (uint8 j = 0; j < 6; j++){
            bytes memory result = new bytes(8);
            for (uint8 i = 0; i < 8; i++) {
                result[i] = (b[j] & bytes1(uint8(2 ** (7 - i)))) != 0 ? bytes1("1") : bytes1("0");
            }
            fill[j] = string(result);
        }
        return fill;
    }

    function allowlistMint() external payable callerIsUser {
        uint256 price = uint256(0);//vendingMachine.mintlistPrice);
        require(price != 0, "Wait");
        require(candyCollection.allowlist[msg.sender] > 0, "Not Eligible");
        require(totalSupply() + 1 <= candyCollection.AUTHORIZATION, "Too much candy.");
        candyCollection.allowlist[msg.sender]--;
        _safeMint(msg.sender, 1);
        refundIfOver(price);
    }

    /*function auctionMint(uint256 quantity) external payable callerIsUser {

    }*/

    function isPublicSaleOn(
        uint256 publicPriceWei,
        uint256 publicSaleKey,
        uint256 publicSaleStartTime
    ) public view returns (bool) {
        return
        publicPriceWei != 0 &&
        publicSaleKey != 0 &&
        block.timestamp >= publicSaleStartTime;
    }



    /*
    function getAuctionPrice(uint256 _saleStartTime)
    public
    view
    returns (uint256)
    {

    }

    function endAuctionAndSetupNonAuctionSaleInfo(
        uint64 mintlistPriceWei,
        uint64 publicPriceWei,
        uint32 publicSaleStartTime
    ) external onlyOwner {

    }

    function setAuctionSaleStartTime(uint32 timestamp) external onlyOwner {
        //saleConfig.auctionSaleStartTime = timestamp;
    }*/

    receive() external payable {}

    function mint(uint256 quantity) external payable callerIsUser {

        uint256 publicPrice = 1 ether;
        /*Vending memory config = saleConfig;
        uint256 publicSaleKey = uint256(config.publicSaleKey);

        uint256 publicSaleStartTime = uint256(config.publicSaleStartTime);
        require(
            publicSaleKey == callerPublicSaleKey,
            "called with incorrect public sale key"
        );

        require(
            isPublicSaleOn(publicPrice, publicSaleKey, publicSaleStartTime),
            "public sale has not begun yet"
        );*/

        require(
            (totalSupply() + quantity <= candyCollection.AUTHORIZATION) || (_numberMinted(msg.sender) + quantity <= 5),
            "Too much Candy."
        );

        _mint(msg.sender, quantity);
        refundIfOver(publicPrice * quantity);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "More ETH"); //if message value is greater than or equal to price, run refund. else, don't run refund because its the correct amount
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    /*function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory)
    {
        return _ownershipOf(tokenId);
    }*/

    /*** rescue functions ***/

    function withdrawMoney(address tokenAddress) external onlyOwner {
        if(tokenAddress.code.length > 0){ //is an already deployed smart contract
            // Create an instance of the ERC20 token using the provided token address
            IERC20 token = IERC20(tokenAddress);

            // Check the contract's balance of the specified token
            uint256 contractTokenBalance = token.balanceOf(address(this));

            // Ensure the contract has enough balance to fulfill the withdrawal request
            require(contractTokenBalance >= 0, "No tokens.");

            // Transfer the specified amount of tokens to the caller (msg.sender)
            token.transfer(msg.sender, contractTokenBalance);
        } else {
            (bool success, ) = msg.sender.call{value: address(this).balance}("");
            require(success, "Transfer failed.");
            candyCollection.reveal = true;
        }
    }

    /*** end rescue functions ***/

    function getBackground(uint16 tokenId) internal view returns (string[2] memory value) {
        idCheck(tokenId);
        string[2] memory bg;
        bg[0] = Strings.toHexString(candyCollection.attributeBackground[generateAttributes(tokenId)[0]][0]);
        bg[1] = Strings.toHexString(candyCollection.attributeBackground[generateAttributes(tokenId)[0]][1]);
        return bg;
    }

    function generateAttributes(uint256 seed) internal pure returns (uint8[6] memory) {
        uint8[6] memory randomValues;
        for (uint8 i = 0; i < 6; i++) {
            seed = uint256(keccak256(abi.encodePacked(seed)));
            randomValues[i] = uint8(seed % 10);
        }
        return randomValues;
    }

    function getCandyAttributes(uint8 control, uint16 tokenId) public view returns(string memory value) {
        idCheck(tokenId);
        uint8[6] memory candyFeatures = generateAttributes(tokenId);

        if(control == 0){ // background
            string[2] memory background = getBackground(tokenId);
            return candyCollection.reveal ? string(abi.encodePacked('#', background[0], ' #', background[1])) : "#FFFFFF #000000";
        } else if(control == 1){ // wrapper ends
            return candyCollection.reveal ? Strings.toHexString(candyCollection.attributeWrapperEnds[candyFeatures[1]]) : "000000";
        } else if(control == 2){ //wrapper highlights
            return candyCollection.reveal ? Strings.toHexString(candyCollection.attributeWrapperHighlights[candyFeatures[2]]) : "FFFFFF";
        } else if(control == 3){ //wrapper body
            return candyCollection.reveal ? Strings.toHexString(candyCollection.attributeWrapperBody[candyFeatures[3]]) : "000000";
        } else if(control == 4){ //wrapper stripes
            return candyCollection.reveal ? Strings.toHexString(candyCollection.attributeWrapperStripes[candyFeatures[4]]) : "000000";
        } else if(control == 5){ //wrapper outer body
            return candyCollection.reveal ? Strings.toHexString(candyCollection.attributeWrapperOuterBody[candyFeatures[5]]) : "000000";
        } else if(control == 6){ //get concatenated description
            uint16 index = candyFeatures[0];

            //can do even and odd variations here to add variation
            string memory description = string(abi.encodePacked(candyCollection.descriptorA[index], ' ', candyCollection.descriptorB[tokenId % 2 == 0 ? index : generateAttributes(index)[0]], ' ', candyCollection.descriptorC[index])); //else condition is a derivative, for entropy

            return description;
        } else {
            return '#000000';
        }
    }

    /*** end attribute functions ***/

    /*
        Some platforms do not support SVG, this method allows switching to a raster image

    */
    function renderMode(uint16 tokenId) external payable callerHasTokenId(tokenId) {
        candyCollection.uriMode[tokenId]?  candyCollection.uriMode[tokenId] = false :  candyCollection.uriMode[tokenId] = true;
        refundIfOver(candyCollection.modePrice);
    }

    /**
     * @dev Returns an SVG string representation of the candy associated with the given tokenId.
     * The SVG string can be used by browsers and other clients to quickly render the candy's image.
     * @param tokenId The uint16 tokenId representing the specific candy.
     * @return A bytes containing the SVG data for the candy associated with the tokenId, in base64 format
     */
    function wrappedCandy(uint16 tokenId) public view returns(string memory){
        idCheck(tokenId);
        //st0 is background
        //st1 is wrapper ends
        //st2 is highlights
        //st3 is wrapper body
        //st4 is stripes
        //st5 is wrapper outer body

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" xmlns:xlink="http://www.w3.org/1999/xlink" ',
            'viewBox="0 0 800 800" style="enable-background:new 0 0 800 800;" xml:space="preserve">',
                wrappedCandyGenerateStyleBlock(tokenId),
                wrappedCandyGenerateCandyBlock(generateAttributes(tokenId), tokenId),
                wrappedCandyGenerateGradientBlock(tokenId),
            '</svg>'
        );

        return string(abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
               ));
    }

    function wrappedCandyGenerateStyleBlock(uint16 tokenId) internal view returns (bytes memory){
        return abi.encodePacked(
                        '<style type="text/css">',
                        '.st1{fill:#', getCandyAttributes(1, tokenId),';}',
                        '.st2{fill:#', getCandyAttributes(2, tokenId),';}',
                        '.st3{fill:#', getCandyAttributes(3, tokenId),';}',
                        '.st4{fill:#', getCandyAttributes(4, tokenId),';}',
                        '.st5{opacity:0.5;fill:#', getCandyAttributes(5, tokenId),';}',
                        '.st6{fill:none;}',
                        '.st7{font-family:\'Impact\'; opacity:1; -webkit-text-stroke: 2px white; fill:#', candyCollection.reveal ? getCandyAttributes(5, tokenId) : "FFFFFF",'; stroke:#', candyCollection.reveal ? getCandyAttributes(2, tokenId) : "FFFFFF",';}',
                        '.st8{font-size:30px;}',
                        '.st3bg{fill:#', getCandyAttributes(3, tokenId),';}',
                        '',
                        '.fade-in-path{',
                        'opacity:100%;',
                        'transition:0.5s;',
                        '}',
                        '',
                        '.fade-in-path:hover{',
                        'opacity:20%;',
                        'transition:opacity 1s;',
                        '}',
                        '.fade-in-path:active{',
                        'opacity:20%;',
                        'transition:opacity 1s;',
                        '}',
                        '',
                        '@keyframes opacity{',
                        '  15% {opacity:1}',
                        '  35% {opacity:1}',
                        '  65% {opacity:0}',
                        '}',
                        '',
                        '.f{',
                        'animation-name: f;',
                        'animation-duration: 3s;',
                        'animation-iteration-count: infinite;',
                        'animation-timing-function: ease-in-out;',
                        'margin-left: 30px;',
                        'margin-top: 5px;',
                        '}',
                        '',
                        '@keyframes f{',
                        '0%{transform:translate(0,0px);}',
                        '50%{transform:translate(0,15px);}',
                        '100%{ transform:translate(0,-0px);}',
                        '}',
                        '',
                        '.fd {',
                        'animation-name: fd;',
                        'animation-delay: 0.5s;',
                        'animation-duration: 3s;',
                        'animation-iteration-count: infinite;',
                        'animation-timing-function: ease-in-out;',
                        '}',
                        '',
                        '@keyframes fd {',
                        '0%{transform:translate(0,0px);}',
                        '50%{transform:translate(0,30px);}',
                        '100%{transform:translate(0,-0px);}',
                        '}',
                        '</style>'
        );
    }

    function wrappedCandyGenerateCandyBlock(uint8[6] memory candyFeatures, uint16 tokenId) internal view returns (bytes memory){

        //used exclusively for descriptors
        uint16 index = candyFeatures[0];
        string memory daoCount = Strings.toString(candyCollection.daoRegistryCount[uint16(tokenId)]);
        string memory NFTID = Strings.toString(tokenId);
        string[6] memory barcode = bytesToBinaryString([bytes1(candyFeatures[0]), bytes1(candyFeatures[1]), bytes1(candyFeatures[2]),
                                                bytes1(candyFeatures[3]), bytes1(candyFeatures[4]), bytes1(candyFeatures[5])]);

        return abi.encodePacked(
                        '<rect class="st0" fill="url(#d)" rx="15" width="800" height="800"/>',
                        '<rect x="340.6" y="351" class="st6" width="211" height="147"/>',
                        '<g class="f">',
                        '<path id="st3bg" class="st3bg" d="M276.6,556.6c42,40.4,84.9,53.9,143.6,49.4c75.4-5.9,171-88.2,168.8-187.3',
                        'c-1.8-80-41.9-125.6-71.1-146.3c-26.9-19.1-68.6-45.6-132-38.9c-76.1,8-167.2,87.2-167.8,182.8C217.6,492.7,244.4,525.5,276.6,556.6',
                        'z"/>',
                        '<g class="fd" style="opacity: ',candyCollection.reveal ?'1':'0',';">',
                        '<text transform="matrix(1 0 0 1 340.6391 363.6001)">',
                        '<tspan x="0" y="-20.2" class="st7 st8">',candyCollection.descriptorA[index],'</tspan>',
                        '<tspan x="0" y="20" class="st7 st8">',candyCollection.descriptorB[tokenId % 2 == 0 ? index : generateAttributes(index)[0]],'</tspan>',
                        '<tspan x="0" y="63.2" class="st7 st8">',candyCollection.descriptorC[index],'</tspan>',
                        '<tspan x="0" y="100" class="st7 st8" style="font-size: 18px;">NFT ID: ', NFTID ,'</tspan>',
                        '<tspan x="0" y="120" class="st7 st8" style="font-size: 18px;">DAOs Registered: ', daoCount, '</tspan>',
                        '<tspan x="0" y="140" class="st7 st8" style="font-size: 14px; fill: none;">[ ',barcode[0],' ',barcode[1],' ',barcode[2],' ]</tspan>',
                        '<tspan x="0" y="160" class="st7 st8" style="font-size: 14px; fill: none;">[ ',barcode[3],' ',barcode[4],' ',barcode[5],' ]</tspan>',
                        '</text>',
                        '</g>',
                        '<g class="fd" style="opacity: ',candyCollection.reveal ?'0':'1',';">',
                        '<text transform="matrix(1 0 0 1 340.6391 363.6001)">',
                        '<tspan x="20" y="150" class="st7" style="font-size: 250px;">?</tspan>',
                        '</text>',
                        '</g>'
                        '<path id="st1" class="st1" d="M94.6,635c0,0-26.7-4.9-42.1-14.8s-33-26-30.9-30.9s21.7-9.8,61.1-28.1s92.7-49.2,127.8-48.4',
                        's52.7,14.1,52.7,14.1s62.4,37.8,56.6,109.4c-4.7,58.1-24.1,84.1-41.1,115.9c-7.1,13.3-7.8,29.7-14.9,31.1c-7,1.4-18.4-6.9-26-13.4',
                        'c-12.8-10.9-20.5-34.1-36.9-43.3s-41.4-9.2-62.3-24.1C100,674.9,94.6,635,94.6,635z"/>',
                        '<path id="st2" class="st2" d="M82,593.2c-0.6,5.7,14.6,13.4,25.3,12.2s27.8-10.3,49.8-20.7c26-12.2,62.4-21.4,59.7-32.9',
                        's-38.6-2.3-66.2,7.6C123,569.5,82.8,586,82,593.2z M215.6,618.6c-4.5-9.3-24.9-5-49.8,2.3s-36.7,11.9-39.4,26',
                        'c-2.7,13.8,5.4,23.3,15.7,30.6s22.6,12.6,29.4,12.3c6.9-0.4,11.5-2.3,15.7-12.6c2.5-6.2,5.5-15.6,11.5-24.9',
                        'C205.6,641.6,220.6,629,215.6,618.6L215.6,618.6z M228.1,732.5c0,10,13,26.8,22.6,23.8c10.8-3.4,10.1-26.7,15.7-54.3',
                        'c8.8-43.6,18.9-70.2,6.1-74.2c-8.4-2.7-22.6,32.5-29.9,53.9C237.3,697.7,228.1,720.3,228.1,732.5L228.1,732.5z"/>',
                        '<path class="st1" d="M506.8,290.1c32.3,30.3,78.2,46.1,132.8,16.2c42.6-23.3,57.6-54.1,87.9-73c30.3-18.9,48.8-16.7,48.4-21.6',
                        'c-0.4-4.8-15.8-20.2-32.6-28.1c-16.7-7.9-31.7-4.8-41.3-12.8c-9.6-7.9-11-34.3-29.4-49.7s-33.9-13.2-48.4-27.2S605.3,59.2,589,45.1',
                        's-36.9-26.8-41.8-23.8s-2.2,14.1-11.9,46.6c-9.7,32.6-51.9,98.1-55.4,146.9C477.6,249.2,485.8,270.3,506.8,290.1z"/>',
                        '<path class="st2" d="M517.9,240c8.9,5.1,20-45.4,37.5-73s34.1-42.9,34.1-53.4S574.2,76,563.3,78.2s-10.6,19.9-12.9,27.6',
                        'c-2.7,8.7-20.8,46.6-26.6,59.7C515.3,184.4,503.6,231.9,517.9,240L517.9,240z M558.3,242.7c5.8,5.1,21.7-9.7,49.3-35.6',
                        'c30-28.1,40.2-41.4,28.1-53.7c-11.1-11.1-24.2-1.9-41.3,20.8C581.8,190.9,551.5,236.7,558.3,242.7z M606.3,252.4',
                        'c2.9,8.1,42.8-7.7,59.9-13.1c17.2-5.3,38.7-15.5,38.7-26.1s-13.1-20.8-26.4-19.1c-13.3,1.7-36.7,23.8-44,29.8',
                        'C624.1,232.4,604.3,247.1,606.3,252.4L606.3,252.4z"/>',
                        '<g class="fade-in-path"',candyCollection.reveal ? '' : ' style="opacity: 0;"','>',
                        '<path id="st3" class="st3" d="M276.6,556.6c42,40.4,84.9,53.9,143.6,49.4c75.4-5.9,171-88.2,168.8-187.3',
                        'c-1.8-80-41.9-125.6-71.1-146.3c-26.9-19.1-68.6-45.6-132-38.9c-76.1,8-167.2,87.2-167.8,182.8C217.6,492.7,244.4,525.5,276.6,556.6',
                        'z"/>',
                        '<path id="st4" class="st4" d="M334,545.8c60.6,27.6,80.3,60.6,80.3,60.6s12.4-0.6,23.8-3.1c13.4-2.9,24.1-7.6,24.1-7.6',
                        's-26.1-35.3-63.9-57.1c-41.1-23.6-75.8-38.8-106.8-44.7s-63.9-8.6-63.9-8.6s3.2,10.4,9.8,22.9c5.2,9.9,9.3,14.9,9.3,14.9',
                        'S283.5,522.7,334,545.8L334,545.8z M219.2,442.5c0,0,25.6-4.7,74.4,7.3c23.6,5.8,54.6,15.4,88.9,31.5c30.7,14.4,52.7,28.3,70.9,40.4',
                        'c42.8,28.3,54.9,47.8,54.9,47.8s8.8-6.3,15.8-12.8c7-6.4,14.6-14.8,14.6-14.8s-18.1-33.1-96.6-76.9s-127.6-55.6-161.2-60.3',
                        'c-33.6-4.8-61.8-4-61.8-4s-1,11.2-0.9,20.8C218.1,433.5,219.2,442.5,219.2,442.5L219.2,442.5z M230.2,357c0,0,99.1,2.8,185.6,46.7',
                        'c80.5,40.8,148.6,103.8,148.6,103.8s5.7-8.8,10.8-20.4c5.8-13.2,8.4-24.6,8.4-24.6s-13.1-14.3-43.4-35.5',
                        'c-25.5-17.8-61.6-43.4-113.7-66.3c-42.6-18.7-75-26.7-102.6-33.1c-44.1-10.2-72.6-8.6-72.6-8.6s-5.6,6.9-11.7,18.4',
                        'C233.5,348.5,230.2,357,230.2,357L230.2,357z M286.1,280.3c0,0,67.4,2.4,165.2,45.8c37.9,16.8,62.1,31.5,82.9,45.8',
                        'c38.3,26.3,54.8,46.9,54.8,46.9s-0.6-17.4-2.8-31.2c-2.4-15.3-6.4-27.3-6.4-27.3s-35.5-34.8-108.6-67.9',
                        'C401.1,260.6,331.5,250,331.5,250s-11,4.7-23.9,13.6C297.8,270.3,286.1,280.3,286.1,280.3L286.1,280.3z"/>',
                        '</g>',
                        '<path class="st2" d="M258.5,452.8c7.4,34,31.3,68.4,52.9,77.1c21.9,8.8,32.8-6.3,28.2-21.2c-4.6-14.9-26.2-35.1-31.9-67.3',
                        's-2.6-59.5,1.1-73s2.6-24.6-7.8-27.4c-9.9-2.7-23.2,2.7-34.8,25.4C253.5,391.4,253.1,427.8,258.5,452.8L258.5,452.8z"/>',
                        '<path id="st5" class="st5" d="M386,233.4c-76.1,8-167.2,87.2-167.8,182.8c-0.5,76.4,26.3,109.3,58.6,140.4',
                        'c42,40.4,84.9,53.9,143.6,49.4c75.4-5.9,171-88.2,168.8-187.3c-1.8-80-41.9-125.6-71.1-146.3C491.1,253.2,449.4,226.7,386,233.4',
                        'L386,233.4z M502.4,293c25.3,18,60,57.4,61.5,126.6c1.9,85.8-80.8,156.9-146.1,162.1c-50.8,4-87.9-7.7-124.2-42.7',
                        'c-27.9-26.9-51.1-55.3-50.6-121.4c0.5-82.7,79.4-151.3,145.2-158.2C443.1,253.6,479.1,276.5,502.4,293L502.4,293z"/>',
                        '</g>'

        );
    }

    function wrappedCandyGenerateGradientBlock(uint16 tokenId) internal view returns (bytes memory){
        return abi.encodePacked(
                '<defs>',
                '<linearGradient id="d" x1="30%" y1="70%">',
                '<stop offset="0%" stop-color="#', candyCollection.reveal ? getBackground(tokenId)[0] :'000000','">',
                '  <animate attributeName="stop-color" values="#', candyCollection.reveal ? getBackground(tokenId)[0]:'000000',';#', candyCollection.reveal ? getBackground(tokenId)[1]:'ffffff',';" dur="1.5s" repeatCount="1" fill="freeze"/>',
                '</stop>',
                '<stop offset="100%" stop-color="', candyCollection.reveal ? getBackground(tokenId)[1] :'#ffffff','">',
                '  <animate attributeName="stop-color" values="#', candyCollection.reveal ? getBackground(tokenId)[1]:'ffffff',';#', candyCollection.reveal ? getBackground(tokenId)[0]:'000000','" dur="3s" fill="freeze" />',
                '</stop>',
                '</linearGradient>',
                '</defs>'
            );
    }

    function wrappedCandyAttributes(string memory background, string memory daoCount, uint16 tokenId) internal view returns (bytes memory){
        return abi.encodePacked(
                '"attributes": [',
                '{',
                '"trait_type": "Name",',
                '"value": "', getCandyAttributes(6, uint16(tokenId)), '"',
                '},',
                '{',
                '"trait_type": "Background",',
                '"value": "', candyCollection.reveal ? background: "#FFFFFF #000000", '"',
                '},',
                '{',
                '"trait_type": "Twist Ties",',
                '"value": "#', getCandyAttributes(1, uint16(tokenId)) , '"',
                '},'
                '{',
                '"trait_type": "Accent",',
                '"value": "#', getCandyAttributes(2, uint16(tokenId)) , '"',
                '},'
                '{',
                '"trait_type": "Body",',
                '"value": "#', getCandyAttributes(3, uint16(tokenId)) , '"',
                '},'
                '{',
                '"trait_type": "Stripes",',
                '"value": "#', getCandyAttributes(4, uint16(tokenId)) , '"',
                '},'
                '{',
                '"trait_type": "Outline",',
                '"value": "#', getCandyAttributes(5, uint16(tokenId)) , '"',
                '},',
                '{',
                '"trait_type": "DAOs Registered",',
                '"value": "', daoCount , '"'
                '}',
                ']'
        );
    }

    //on PFPMode, use super
    function tokenURI(uint256 tokenId) override public view returns (string memory){
        idCheck(uint16(tokenId));
        //st0 is background
        //st1 is wrapper ends
        //st2 is highlights
        //st3 is wrapper body
        //st4 is stripes
        //st5 is wrapper outer body

        string memory background = string(abi.encodePacked('#', getBackground(uint16(tokenId))[0], ' #', getBackground(uint16(tokenId))[1]));

        string memory daoCount = Strings.toString(candyCollection.daoRegistryCount[uint16(tokenId)]);

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Candy #', Strings.toString(tokenId), ': ', getCandyAttributes(6, uint16(tokenId)), '",',
                '"description": ', unicode'"🍬 wrapper.fi 🍬 Candy NFT Collection on Chain ID: ', Strings.toString(block.chainid),'",',// ,
                '"image": "', candyCollection.uriMode[uint16(tokenId)] ? super.tokenURI(tokenId) : wrappedCandy(uint16(tokenId)), '",', //do conditional baseUri here ownerTokenIdToIndex[msg.sender][tokenId]
                wrappedCandyAttributes(background, daoCount, uint16(tokenId)),
            '}'
        );

        return string(abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
        );
    }
}
