// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IResourceToken.sol";
import "hardhat/console.sol";

contract Wilderness is ReentrancyGuard {
    IERC721 public avatarAddress;
    IResourceToken public resourceTokenAddress;

    uint256 public sticksId;
    uint256 public stonesId;
    uint256 public plantFiberId;
    uint256 public appleId;
    uint256 public constant DURATION = 1 minutes;
    uint256 public constant STICKS_AMOUNT = 10;
    uint256 public constant STONES_AMOUNT = 8;
    uint256 public constant PLANTFIBER_AMOUNT = 4;
    uint256 public constant APPLE_AMOUNT = 2;

    // owner => avatarId => startTime
    mapping(address => mapping(uint256 => uint256)) public sessions;

    event AvatarEntered(
        address indexed owner,
        uint256 avatarId,
        uint256 timestamp
    );
    event AvatarExited(
        address indexed owner,
        uint256 avatarId,
        uint256 timestamp
    );

    constructor(
        address _avatarAddress,
        address _resourceTokenAddress,
        uint256 _sticksId,
        uint256 _stonesId,
        uint256 _plantFiberId,
        uint256 _appleId
    ) {
        avatarAddress = IERC721(_avatarAddress);
        resourceTokenAddress = IResourceToken(_resourceTokenAddress);
        sticksId = _sticksId;
        stonesId = _stonesId;
        plantFiberId = _plantFiberId;
        appleId = _appleId;
    }

    function sendAvatar(uint256 avatarId) external {
        require(
            avatarAddress.ownerOf(avatarId) == msg.sender,
            "You do not own this avatar"
        );

        avatarAddress.transferFrom(msg.sender, address(this), avatarId);
        sessions[msg.sender][avatarId] = block.timestamp;

        emit AvatarEntered(msg.sender, avatarId, block.timestamp);
    }

    function retrieveAvatar(uint256 avatarId) external nonReentrant {
        require(sessions[msg.sender][avatarId] > 0, "Session not found");
        require(
            block.timestamp >= sessions[msg.sender][avatarId] + DURATION,
            "Foraging not complete"
        );

        delete sessions[msg.sender][avatarId];

        avatarAddress.transferFrom(address(this), msg.sender, avatarId);

        uint256[] memory ids = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        ids[0] = sticksId;
        amounts[0] = STICKS_AMOUNT;
        ids[1] = stonesId;
        amounts[1] = STONES_AMOUNT;
        ids[2] = plantFiberId;
        amounts[2] = PLANTFIBER_AMOUNT;
        ids[3] = appleId;
        amounts[3] = APPLE_AMOUNT;

        resourceTokenAddress.mintBatch(msg.sender, ids, amounts, "");

        emit AvatarExited(msg.sender, avatarId, block.timestamp);
    }
}
