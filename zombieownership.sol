pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

/// @title A contract that manages transferring zombie ownership
/// @author Your Name
/// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft
contract ZombieOwnership is ZombieAttack, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) zombieApprovals;

  /// @notice Get the balance of zombies owned by a specific address
  /// @param _owner The address to query for the balance
  /// @return The number of zombies owned by `_owner`
  function balanceOf(address _owner) external view returns (uint256) {
    return ownerZombieCount[_owner];
  }

  /// @notice Find the owner of a specific zombie by its token ID
  /// @param _tokenId The ID of the zombie
  /// @return The address currently owning the zombie
  function ownerOf(uint256 _tokenId) external view returns (address) {
    return zombieToOwner[_tokenId];
  }

  /// @notice Internal function to transfer ownership of a zombie
  /// @param _from The address of the current owner
  /// @param _to The address of the new owner
  /// @param _tokenId The ID of the zombie being transferred
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);  // Fire the Transfer event as per ERC721
  }

  /// @notice Transfer a zombie from one address to another
  /// @dev The caller must either own the zombie or be approved to transfer it
  /// @param _from The current owner's address
  /// @param _to The new owner's address
  /// @param _tokenId The ID of the zombie being transferred
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  /// @notice Approve another address to transfer the specified zombie on behalf of the owner
  /// @dev Only the owner of the zombie can call this function
  /// @param _approved The address that is approved to transfer the zombie
  /// @param _tokenId The ID of the zombie to approve for transfer
  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);  // Fire the Approval event using msg.sender as the owner
  }

}
