// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin with timer for guardianship.
/// @author Zolidity (https://github.com/z0r0z/zolidity/blob/main/src/auth/OwnedWithTimer.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)

interface IERC721 {
  function ownerOf(uint256 tokenId) external view returns (address owner);
}


contract OwnedWithTimer {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnershipTransferred(address indexed operator, address indexed owner);

    event GuardSet(address indexed collection, uint256 indexed tokenId);

    event CheckedIn(uint256 checkIn);

    event TimespanSet(uint48 timespan);

    /// -----------------------------------------------------------------------
    /// Custom Errors
    /// -----------------------------------------------------------------------

    error Unauthorized();

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    address public owner;

    modifier onlyOwner() virtual {
        if (msg.sender != owner) revert Unauthorized();

        _;
    }

    /// -----------------------------------------------------------------------
    /// Timer Storage
    /// -----------------------------------------------------------------------

    address public collection;
    uint256 public tokenId;

    uint48 public checked;

    uint48 public timespan;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address _owner,
        address _collection,
        uint256 _tokenId,
        uint48 _timespan
    ) {
        owner = _owner;

        collection = _collection;
        
        tokenId = _tokenId;

        checked = uint48(block.timestamp);

        timespan = _timespan;

        emit OwnershipTransferred(address(0), _owner);

        emit Guard(_collection, _tokenId);

        emit TimespanSet(_timespan);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    function transferOwnership(address _owner) public payable virtual {
        if (msg.sender != owner) {
            unchecked {
                if (msg.sender != IERC721(collection).ownerOf(tokenId) ||
                    block.timestamp <= checked + timespan)
                        revert Unauthorized();
            }
        }

        owner = _owner;

        emit OwnershipTransferred(msg.sender, _owner);
    }

    /// -----------------------------------------------------------------------
    /// Timer Logic
    /// -----------------------------------------------------------------------

    function checkIn() public payable virtual onlyOwner {
        checked = uint48(block.timestamp);

        emit CheckedIn(block.timestamp);
    }

    function setKey(address _collection, uint256 _tokenId) public payable virtual onlyOwner {
        collection = _collection;

        tokenId = _tokenId;

        emit GuardSet(_collection, _tokenId);
    }

    function setTimespan(uint48 _timespan) public payable virtual onlyOwner {
        timespan = _timespan;

        emit TimespanSet(_timespan);
    }
}