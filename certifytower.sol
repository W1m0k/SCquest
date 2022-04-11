// SPDX-License-Identifier: MIT
// author: yoyoismee.eth -- it's opensource but also feel free to send me coffee/beer.
pragma solidity 0.8.13;
//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IRaids {
    // ## Have chance to drop rare item
    //function levelUp(uint256 _tokenID) external view returns (bool);

    function climbing(string calldata _data) external returns (bool);
}

contract Certificate is ERC721, Ownable {
    using Strings for uint256;

    string part1 =
        '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="700" version="1.1"><style>.small { font: italic 25px sans-serif; } .mini { font: italic 20px sans-serif; } .heavy { font: bold 35px sans-serif; }</style>  <text x="300" y="200" class="heavy">Certify Smart Contract Developer lv ';
    string part2 =
        '</text>  <text x="250" y="300" class="small">This certificate is awarded to :  ';
    string defaultOwner = "the owner of this NFT";
    string part3 =
        '</text>  <text x="200" y="350" class="mini">The Owner of this certificate either have good knowledge about smart contract.</text>  <text x="200" y="400" class="mini">or spent enough money to buy one</text>  <text x="600" y="600" class="mini">Certify by: yoyoismee.eth</text></svg>';

    mapping(address => string) ownerNames;
    mapping(address => uint256) level;
    mapping(uint256 => address) levelAddr;
    mapping(address => uint256) levelTokenID;

    constructor() ERC721("Certify Tower", "CTW") {}

    function setLevelAddr(uint256 _lvl, address _lvlAddr) public onlyOwner {
        levelAddr[_lvl] = _lvlAddr;
    }

    function ad2uint(address a) internal pure returns (uint256) {
        return uint256(uint160(a));
    }

    function raids(uint256 _lvl, string calldata _data) public {
        require(level[msg.sender] <= _lvl, "invalid level");
        require(levelAddr[_lvl] != address(0), "invalid stage");

        bool isPassed = IRaids(levelAddr[_lvl]).climbing(_data);

        if (isPassed) {
            level[msg.sender] = _lvl;
            uint256 tokenID = ad2uint(msg.sender) + ad2uint(levelAddr[_lvl]);
            levelTokenID[tokenID] = _lvl;
            if (!_exists(tokenID)) {
                _mint(msg.sender, tokenID);
            }

            if (_lvl == 1) ownerNames[msg.sender] = _data;
        }
    }

    // boring stuff
    function contractURI() external pure returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Certify Smart Contract Developer","description": "The Owner of this certificate either have good knowledge about smart contract or spent enough money to buy one","seller_fee_basis_points": 1000,"fee_recipient": "0x6647a7858a0B3846AbD5511e7b797Fc0a0c63a4b"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function tokenURI(uint256 tokenID)
        public
        view
        override
        returns (string memory)
    {
        require(levelTokenID[tokenID] > 0, "not exist");
        string memory output = string(
            abi.encodePacked(
                part1,
                Strings.toString(levelTokenID[tokenID]),
                part2,
                ownerNames[owner()],
                part3
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Smart Contract Developer Certificate #',
                        Strings.toString(tokenID),
                        '", "description": "The Owner of this certificate either have good knowledge about smart contract or spent enough money to buy one", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
