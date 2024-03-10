// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Wilderness {
    IERC721 public avatarAddress;
    IERC1155 public resourceTokenAddress;

    uint256 public sticksId;
    uint256 public stonesId;
    uint256 public constant DURATION = 1 minutes;
    uint256 public constant STICKS_AMOUNT = 10;
    uint256 public constant STONES_AMOUNT = 8;

    // owner => avatarId => startTime
    mapping(address => mapping(uint256 => uint256)) public sessions;

    constructor(
        address _avatarAddress,
        address _resourceTokenAddress,
        uint256 _sticksId,
        uint256 _stonesId
    ) {
        avatarAddress = IERC721(_avatarAddress);
        resourceTokenAddress = IERC1155(_resourceTokenAddress);
        sticksId = _sticksId;
        stonesId = _stonesId;
    }

    function sendAvatar(uint256 avatarId) external {
        require(
            avatarAddress.ownerOf(avatarId) == msg.sender,
            "You do not own this avatar"
        );
        avatarAddress.transferFrom(msg.sender, address(this), avatarId);
        sessions[msg.sender][avatarId] = block.timestamp;
    }

    function retrieveAvatar(uint256 avatarId) external nonReentrant {
        require(sessions[msg.sender][avatarId] > 0, "Session not found");
        require(
            block.timestamp >= sessions[msg.sender][avatarId] + DURATION,
            "Foraging not complete"
        );

        delete sessions[msg.sender][avatarId];

        avatarAddress.transferFrom(address(this), msg.sender, avatarId);
        resourceTokenAddress.mint(msg.sender, sticksId, sticksAmount, "");
        resourceTokenAddress.mint(msg.sender, stonesId, stonesAmount, "");
    }
}
