pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'MillerRole' to manage this role - add, remove, check
contract MillerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event MillerAdded(address indexed account);
  event MillerRemoved(address indexed account);

  // Define a struct 'Millers' by inheriting from 'Roles' library, struct Role
  Roles.Role private Millers;

  // In the constructor make the address that deploys this contract the 1st Miller
  constructor() public {
    _addMiller(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyMiller() {
    require(isMiller(msg.sender));
    _;
  }

  // Define a function 'isMiller' to check this role
  function isMiller(address account) public view returns (bool) {
    return Millers.has(account);
  }

  // Define a function 'addMiller' that adds this role
  //function addMiller(address account) public onlyMiller {
  //  _addMiller(account);
  //}

  // Define a function 'renounceMiller' to renounce this role
  function renounceMiller() public {
    _removeMiller(msg.sender);
  }

  // Define an internal function '_addMiller' to add this role, called by 'addMiller'
  function _addMiller(address account) internal {
    Millers.add(account);
    emit MillerAdded(account);
  }

  // Define an internal function '_removeMiller' to remove this role, called by 'removeMiller'
  function _removeMiller(address account) internal {
    Millers.remove(account);
    emit MillerRemoved(account);
  }
}