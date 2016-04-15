/***
@fileOverview https://gist.github.com/d11e9/e1b83749e45207fa34aa
***

contract OwnedAttributeStore {

  struct Attribute {
    address owner;
    address writer;
    address revoker;
    bytes32 value;
  }

  mapping( bytes32 => Attribute ) public attributes;

  modifier onlyAttributeOwner(bytes32 attribute) {
    if (isAttributeOwner(attribute, msg.sender)) { _ }
  }

  modifier onlyAttributeOwnerOrWriter(bytes32 attribute) {
    if (isAttributeOwner(attribute, msg.sender) || isAttributeWriter(attribute, msg.sender)) { _ }
  }

  modifier onlyAttributeOwnerOrRevoker(bytes32 attribute) {
    if (isAttributeOwner(attribute, msg.sender) || isAttributeRevoker(attribute, msg.sender)) { _ }
  }

  function OwnedAttributeStore() {
    /*
      not using setAttributeAndOwner as 'owner' attribute is special
      and required to be set for onlyAttributeOwner modifier checks.
    */
    attributes[bytes32("owner")].owner = msg.sender;
    attributes[bytes32("owner")].writer = msg.sender;
    attributes[bytes32("owner")].revoker = msg.sender;
    attributes[bytes32("owner")].value = bytes32(msg.sender);
  }

  function isAttributeOwner(bytes32 attribute, address addr) private constant returns(bool) {
    bool defaultOwner = attributes[attribute].owner == address(0);
    if ((defaultOwner && bytes32(addr) == getAttribute("owner").value)
    || (!defaultOwner && attributes[attribute].owner == addr)) return true;
  }

  function isAttributeWriter(bytes32 attribute, address addr) private constant returns(bool) {
    bool defaultWriter = attributes[attribute].owner == address(0);
    if ((defaultWriter && bytes32(addr) == getAttribute("owner").value)
    || (!defaultWriter && attributes[attribute].writer == addr)) return true;
  }

  function isAttributeRevoker(bytes32 attribute, address addr) private constant returns(bool) {
    bool defaultRevoker = attributes[attribute].revoker == address(0);
    if ((defaultRevoker && bytes32(addr) == getAttribute("owner").value)
      || (!defaultRevoker && attributes[attribute].revoker == addr)) return true;
  }

  function getAttribute(bytes32 attribute) private returns (Attribute) { return attributes[attribute]; }
  function getAttributeValue(bytes32 attribute) constant public returns(bytes32) { return attributes[attribute].value; }

  function setAttributeWriter(bytes32 attribute, address newWriter) onlyAttributeOwner(attribute) {
    attributes[attribute].writer = newWriter;
  }

  function setAttributeRevoker(bytes32 attribute, address newRevoker) onlyAttributeOwner(attribute) {
    attributes[attribute].revoker = newRevoker;
  }

  function setAttributeOwner(bytes32 attribute, address newOwner) onlyAttributeOwner(attribute) {
    attributes[attribute].owner = newOwner;
  }

  function revokeAttribute(bytes32 attribute) onlyAttributeOwnerOrRevoker(attribute) {
    attributes[attribute].value = bytes32(0);
  }

  function setAttribute(bytes32 attribute, bytes32 value) onlyAttributeOwnerOrWriter(attribute) {
    attributes[attribute].value = value;
  }

  function transfer(address newOwner) { setAttributeOwner(bytes32("owner"), newOwner); }

}
