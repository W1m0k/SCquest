pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

contract Level1 {
    mapping(uint256 => bool) passed;

    function ad2uint(address a) internal pure returns (uint256) {
        return uint256(uint160(a));
    }

    function climbing(string calldata _data) external returns (bool) {
        uint256 tokenID = ad2uint(tx.origin);

        /*
        TO DO
         */
        // console.log("msg.sender %s", msg.sender);
        // console.log("tx.origin %s", tx.origin);
        // console.log("_data %s", _data);
        // console.log("tokenID %s", tokenID);

        uint256 test1 = uint256(
            keccak256(abi.encodePacked("My name is : ", _data))
        );

        require(test1 % 222 == 0, "failed");

        passed[tokenID] = true;

        return true;
    }

    /*function levelUp(uint256 _tokenID) external view returns (bool) {
        return passed[_tokenID];
    }*/
}
