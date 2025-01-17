// SPDX-License-Identifier: GPL-3.0
pragma  solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract PolyBloom is ERC721, ERC721URIStorage{

    using Counters for Counters.Counter; 

    Counters.Counter private _tokenIdCounter; 

    uint interval; 
    uint lastTimeStamp;

//1차 사진 > ipfs 변환 
//2차 사진 url, 메타데이터(네임, 설명, 이미지url,  ) > ipfs 변환 
//3차 위의 것을 반복했을 때 배열값으로 저장 
//UI에서 한번에 업로드 할 수 있게 설정하기

/*
1차시도
  "https://ipfs.thirdwebcdn.com/ipfs/QmQZzXjVu24gfcr8z7hW7xF8MhGd6YeorGE89rErgbTtZC/0",
  "https://ipfs.thirdwebcdn.com/ipfs/QmSHvPSTJUbbaj7xsm8rJCwx88jeRAtDij94D6pXG9X4mJ/0",
  "https://ipfs.thirdwebcdn.com/ipfs/QmTqVehhJLYHUKqUBb4sotya1mvB5AAx3CZFZ1goGKABdy/0"

2차시도
https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3
https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/seed.json
https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/seedling.json
https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/bloom.json

0x9762213917a68e6770cc805aABb4E695c0220349
0x684e49e76E642bC17848de05b37e0d7956F3e17C


 */


    string[] IpfsUri = [
        "https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/seed.json",
        "https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/seedling.json",
        "https://ipfs.thirdwebcdn.com/ipfs/Qme4pzFWdY3r4e3sMARhtJ23PfSS9AiuynD5J2Zrz8f3U3/bloom.json"
    ];

    constructor(uint _interval ) ERC721("Yongari-POLYdNFTs", "DyNFT"){
        interval = _interval ; 
        lastTimeStamp = block.timestamp;

    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current(); 
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function growFlower(uint256 _tokenId) public{
        if(flowerStage(_tokenId) >= 2){ return; }
        uint256 newVal = flowerStage(_tokenId) + 1;
        string memory newUri = IpfsUri[newVal];
        _setTokenURI(_tokenId, newUri);
    }

    function flowerStage(uint256 _tokenId) public view returns (uint256){
        string memory _uri = tokenURI(_tokenId);
        for (uint256 i = 0; i < IpfsUri.length; i++) {
            if (keccak256(bytes(_uri)) == keccak256(bytes(IpfsUri[i]))) {
                return i;
        }
         }
                return 0;
         }

    /// @dev this method is called by the Automation Nodes to check if `performUpkeep` should be performed
    function checkUpkeep(bytes calldata) external view returns (bool upkeepNeeded, bytes memory){
     upkeepNeeded = (block.timestamp - lastTimeStamp) > interval; 
        //upkeepNeeded = true;
    }

    /// @dev this method is called by the Automation Nodes. it increases all elements which balances are lower than the LIMIT
    function performUpkeep(bytes calldata /* performData */) external  {
        if ((block.timestamp - lastTimeStamp) > interval ){
            lastTimeStamp = block.timestamp; 
            //counter = counter + 1;
            //growFlower(_tokenId);
            growFlower(0);
        }
    }
        function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

}