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
    uint256 public constant DURATION = 1 minutes;
    uint256 public constant STICKS_AMOUNT = 10;
    uint256 public constant STONES_AMOUNT = 8;

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
        uint256 _stonesId
    ) {
        avatarAddress = IERC721(_avatarAddress);
        console.log("Avatar address:");
        console.log(address(avatarAddress));
        resourceTokenAddress = IResourceToken(_resourceTokenAddress);
        console.log("Resource token address:");
        console.log(address(resourceTokenAddress));
        sticksId = _sticksId;
        console.log("Sticks ID:", sticksId);
        stonesId = _stonesId;
        console.log("Stones ID:", stonesId);
    }

    function sendAvatar(uint256 avatarId) external {
        console.log("Sender address:", msg.sender);
        console.log("Avatar ID:", avatarId);
        console.log(address(avatarAddress));
        bool isOwner = avatarAddress.ownerOf(avatarId) == msg.sender;
        console.log("Is sender owner of avatar:", isOwner);

        // If checking for approval directly is relevant
        bool isApproved = avatarAddress.getApproved(avatarId) ==
            address(this) ||
            avatarAddress.isApprovedForAll(msg.sender, address(this));
        console.log("Contract approved to transfer avatar:", isApproved);

        // Check if the contract is approved to transfer the avatar on behalf of the owner
        bool isApprovedForAll = avatarAddress.isApprovedForAll(
            msg.sender,
            address(this)
        );
        bool isDirectlyApproved = avatarAddress.getApproved(avatarId) ==
            address(this);
        console.log("Contract approved for all avatars:", isApprovedForAll);
        console.log(
            "Contract directly approved for this avatar:",
            isDirectlyApproved
        );

        require(
            avatarAddress.ownerOf(avatarId) == msg.sender,
            "You do not own this avatar"
        );

        console.log("Transferring avatar from:", msg.sender, "to contract");
        avatarAddress.transferFrom(msg.sender, address(this), avatarId);
        console.log("Transfer successful");

        sessions[msg.sender][avatarId] = block.timestamp;
        console.log(
            "Session updated for avatar ID:",
            avatarId,
            "at timestamp:",
            block.timestamp
        );

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

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = sticksId;
        amounts[0] = STICKS_AMOUNT;
        ids[1] = stonesId;
        amounts[1] = STONES_AMOUNT;

        resourceTokenAddress.mintBatch(msg.sender, ids, amounts, "");

        emit AvatarExited(msg.sender, avatarId, block.timestamp);
    }
}
