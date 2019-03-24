pragma solidity ^0.4.24;

import "../alpacaaccesscontrol/FarmerRole.sol";
import "../alpacaaccesscontrol/MillerRole.sol";
import "../alpacaaccesscontrol/RetailerRole.sol";
import "../alpacaaccesscontrol/ConsumerRole.sol";


// Define a contract 'Supplychain'
contract SupplyChain is FarmerRole, MillerRole, RetailerRole, ConsumerRole {

  // Define 'owner'
  address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Sheared,  // 0
    RawPacked,  // 1
    RawShipped,     // 2
    RawReceived,    // 3
    Milled,       // 4
    Packed,    // 5
    Shipped,   // 6
    Received,   // 7
    ForSale,    // 8
    Sold  //9
    }

  State constant defaultState = State.Sheared;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originFarmerID; // Metamask-Ethereum address of the Farmer
    string  originFarmName; // Farmer Name
    string  originFarmInformation;  // Farmer Information
    string  originFarmLatitude; // Farm Latitude
    string  originFarmLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address millerID;  // Metamask-Ethereum address of the Miller
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Sheared(uint upc);
  event RawPacked(uint upc);
  event RawShipped(uint upc);
  event RawReceived(uint upc);
  event Milled(uint upc);
  event Packed(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Sheared
  modifier sheared(uint _upc) {
    require(items[_upc].itemState == State.Sheared);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RawPacked
  modifier rawPacked(uint _upc) {
    require(items[_upc].itemState == State.RawPacked);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RawShipped
  modifier rawShipped(uint _upc) {
    require(items[_upc].itemState == State.RawShipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is RawReceived
  modifier rawReceived(uint _upc) {
    require(items[_upc].itemState == State.RawReceived);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Milled
  modifier milled(uint _upc) {
    require(items[_upc].itemState == State.Milled);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Packed
  modifier packed(uint _upc) {
    require(items[_upc].itemState == State.Packed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }

  // Define a function 'shearItem' that allows a farmer to mark an item 'Sheared'
  function shearItem(uint _upc, address _originFarmerID, string _originFarmName, string _originFarmInformation, string  _originFarmLatitude, string  _originFarmLongitude, string  _productNotes)  onlyFarmer public
  { 
    // Increment sku
    sku = sku + 1;

    // Emit the appropriate event
    emit Sheared(_upc);

    // Add the new item as part of Harvest
    items[_upc] = Item({sku: sku, upc: _upc, ownerID: msg.sender, originFarmerID: _originFarmerID,  originFarmName: _originFarmName, originFarmInformation: _originFarmInformation, originFarmLatitude: _originFarmLatitude, originFarmLongitude: _originFarmLongitude, productID: _upc + sku, productNotes: _productNotes, productPrice: 0, millerID: 0, retailerID: 0, consumerID: 0, itemState: State.Sheared});
  }

  // Define a function 'processItem' that allows a farmer to mark an item 'Processed'
  function packRawItem(uint _upc) sheared(_upc) onlyFarmer verifyCaller(items[_upc].ownerID) public 
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[_upc].itemState = State.RawPacked;
    
    // Emit the appropriate event
    emit RawPacked(_upc);
  }


  function shipRawItem(uint _upc, address _millerID) sheared(_upc) onlyFarmer verifyCaller(items[_upc].ownerID) public 
  {
    require(isMiller(_millerID));

    items[_upc].itemState = State.RawShipped;
    items[_upc].ownerID = _millerID;

    emit RawShipped(_upc);
  }


  function receiveRawItem(uint _upc) rawShipped(_upc) onlyMiller verifyCaller(items[_upc].ownerID) public 
  {
    items[_upc].itemState = State.RawReceived;
    items[_upc].millerID = msg.sender;

    emit RawReceived(_upc);
  }


  function millItem(uint _upc) rawReceived(_upc) onlyMiller verifyCaller(items[_upc].ownerID) public 
  {
    items[_upc].itemState = State.Milled;

    emit Milled(_upc);
  }


  function shipItem(uint _upc, address _retailerID) milled(_upc) onlyMiller verifyCaller(items[_upc].ownerID) public 
  {
    require(isRetailer(_retailerID));

    items[_upc].itemState = State.Shipped;
    items[_upc].ownerID = _retailerID;

    emit Shipped(_upc);
  }


  function receiveItem(uint _upc) shipped(_upc) onlyRetailer verifyCaller(items[_upc].ownerID) public 
  {
    items[_upc].itemState = State.Received;
    items[_upc].retailerID = msg.sender;

    emit Received(_upc);
  }


  function sellItem(uint _upc, uint _price) received(_upc) onlyRetailer verifyCaller(items[_upc].ownerID) public 
  {
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;

    emit ForSale(_upc);    
  }


  function buyItem(uint _upc) forSale(_upc) onlyConsumer paidEnough(items[_upc].productPrice) checkValue(_upc) public payable 
  {
    items[_upc].itemState = State.Sold;
    items[_upc].retailerID.transfer(items[_upc].productPrice);
    items[_upc].consumerID = msg.sender;
    items[_upc].ownerID = msg.sender;

    emit Sold(_upc);
  }


  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originFarmerID,
  string  originFarmName,
  string  originFarmInformation,
  string  originFarmLatitude,
  string  originFarmLongitude
  ) 
  {
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    ownerID = items[_upc].ownerID;
    originFarmerID = items[_upc].originFarmerID;
    originFarmName = items[_upc].originFarmName;
    originFarmInformation = items[_upc].originFarmInformation;
    originFarmLatitude = items[_upc].originFarmLatitude;
    originFarmLongitude = items[_upc].originFarmLongitude;
  
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originFarmerID,
  originFarmName,
  originFarmInformation,
  originFarmLatitude,
  originFarmLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  State    itemState,
  address millerID,
  address retailerID,
  address consumerID
  ) 
  {
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    productID = items[_upc].productID;
    productNotes = items[_upc].productNotes;
    productPrice = items[_upc].productPrice;
    itemState = items[_upc].itemState;
    millerID = items[_upc].millerID;
    retailerID = items[_upc].retailerID;
    consumerID = items[_upc].consumerID;
  
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  millerID,
  retailerID,
  consumerID
  );
  }
}