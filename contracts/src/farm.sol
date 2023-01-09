// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @dev Interface for the reward erc20 token.
   @notice token must be mintable.
 */
interface IREWARD {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 _amount) external;
}

contract Farm is Ownable {
    using SafeERC20 for IERC20;
    
    /// @notice Info of each MCV2 user.
    /// `amount` LP token amount the user has provided.
    /// `rewardDebt` The amount of SUSHI entitled to the user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
    }

    IERC20 stToken; /// @notice Address of LP token contract.
    uint256 allocPoint; /// @notice How many allocation points assigned to this pool. to distribute per block.
    uint256 lastRewardBlock; /// @notice Last block number that distribution occurs.
    uint256 accRewardPerShare; /// @notice Accumulated per share, times 1e12. See below.

    /// @notice The REWARD TOKEN!
    IREWARD public RewardToken;
    /// @notice admin address.
    address public admin;
    /// @notice Block number when bonus Reward period ends.
    uint256 public bonusEndBlock;
    /// @notice REWARD tokens created per block.
    uint256 public rewardPerBlock;
    /// @notice Bonus muliplier for early makers.
    uint256 public constant BONUS_MULTIPLIER = 10;
    /// @notice Info of each user that stakes  tokens.
    mapping(address => UserInfo) public userInfo;
    /// @notice Total allocation poitns.
    uint256 public totalAllocPoint = 0;
    /// @notice The block number when mining starts.
    uint256 public startBlock;
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IREWARD _reward,
        IERC20 _stake,
        address _admin,
        uint256 _rewardPerBlock
    ) {
        RewardToken = _reward;
        stToken = _stake;
        admin = _admin;
        rewardPerBlock = _rewardPerBlock;
    }

    /// @notice Update the REWARD allocation point. Can only be called by the owner.
    function set(uint256 _allocPoint) public onlyOwner {
        totalAllocPoint = totalAllocPoint - allocPoint + _allocPoint;
        allocPoint = _allocPoint;
    }

    /// @notice Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return (_to - _from) * (BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to - _from;
        } else {
            return
                (bonusEndBlock - _from) *
                (BONUS_MULTIPLIER) +
                _to -
                bonusEndBlock;
        }
    }

    /// @notice View function to see pending rewards on frontend.
    function pendingRewards(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 Supply = stToken.balanceOf(address(this));
        uint256 RewardPerShare = accRewardPerShare;
        if (block.number > lastRewardBlock && Supply != 0) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
            uint256 Rewards = (multiplier * rewardPerBlock * allocPoint) /
                totalAllocPoint;
            RewardPerShare = accRewardPerShare + (Rewards * 1e12) / Supply;
        }
        return (user.amount * RewardPerShare) / 1e12 - user.rewardDebt;
    }

    /// @notice Update reward variables of the given pool to be up-to-date.
    function update() public {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 Supply = stToken.balanceOf(address(this));
        if (Supply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 Reward = (multiplier * rewardPerBlock * allocPoint) /
            totalAllocPoint;

        RewardToken.mint(admin, Reward / 10);
        RewardToken.mint(address(this), Reward);
        accRewardPerShare = accRewardPerShare + (Reward * 1e12) / Supply;
        lastRewardBlock = block.number;
    }

    /// @notice Deposit tokens to Farm for REWARD allocation.
    function deposit(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        update();
        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare) /
                1e12 -
                user.rewardDebt;
            safeTransfer(msg.sender, pending);
        }
        stToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount + _amount;
        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;
        emit Deposit(msg.sender, _amount);
    }

    /// @notice Withdraw tokens from Farm.
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        update();
        uint256 pending = (user.amount * accRewardPerShare) /
            1e12 -
            user.rewardDebt;
        safeTransfer(msg.sender, pending);
        user.amount = user.amount - _amount;
        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;
        stToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256) public {
        UserInfo storage user = userInfo[msg.sender];
        stToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    /// @notice Safe transfer function.
    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 rewardBal = RewardToken.balanceOf(address(this));
        if (_amount > rewardBal) {
            RewardToken.transfer(_to, rewardBal);
        } else {
            RewardToken.transfer(_to, _amount);
        }
    }

    /// @notice Update admin address by the previous admin.
    function switchAdmin(address _admin) public {
        require(msg.sender == admin, "wut?");
        admin = _admin;
    }
}
