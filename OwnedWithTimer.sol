// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Simple single owner authorization mixin with timer for guardianship.
/// @author Zolidity (https://github.com/z0r0z/zolidity/blob/main/src/auth/OwnedWithTimer.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
contract OwnedWithTimer {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnershipTransferred(address indexed operator, address indexed owner);

    event GuardianSet(address indexed guardian);

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

    address public guardian;

    uint48 public checked;

    uint48 public timespan;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address _owner,
        address _guardian, 
        uint48 _timespan
    ) {
        owner = _owner;

        guardian = _guardian;

        checked = uint48(block.timestamp);

        timespan = _timespan;

        emit OwnershipTransferred(address(0), _owner);

        emit GuardianSet(_guardian);

        emit TimespanSet(_timespan);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    function transferOwnership(address _owner) public payable virtual {
        if (msg.sender != owner) {
            unchecked {
                if (msg.sender != guardian || 
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

    function setGuardian(address _guardian) public payable virtual onlyOwner {
        guardian = _guardian;

        emit GuardianSet(_guardian);
    }

    function setTimespan(uint48 _timespan) public payable virtual onlyOwner {
        timespan = _timespan;

        emit TimespanSet(_timespan);
    }
}