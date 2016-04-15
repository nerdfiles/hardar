
/***
@fileOverview ./contracts/abrogateContract.sol
***/

import "owned";

contract AbrogateOwned is owned {

  address   previousOwner;
  uint8     abrogateV;
  bytes32   abrogateR;
  bytes32   abrogateS;

  function makeRevokable(uint8 _v, bytes32 _r, bytes32 _s) onlyowner {
    /*
      In order to make a contracts ownership abrogateable you must
      provide a signature VRS of a master passphrase which has been
      hashed using SHA3 twice. This can only be done by the current owner.
    */
    abrogateV = _v;
    abrogateR = _r;
    abrogateS = _s;
  }

  function abrogate(bytes32 twiceHashedPassphrase) returns (bool success) {
    /*
      All that is needed to abrogate ownership of the contract is the twice
      hashed passphrase, which can be submitted by any sender.
    */
    if (revokableV != uint8(0)
    && owner != address(0)
    && ecrecover(twiceHashedPassphrase, revokableV, revokableR, revokableS) == owner) {
      previousOwner = owner;
      owner = address(0);
      return true;
    }
  }

  function reclaim(bytes32 onceHashedPassphrase) {
    /*
    You need to be able to provide a once hashed version of the passphrase.
    In order to reclaim ownership of a contract who's ownership has been abrogated
    */
    bytes32 data = sha3(onceHashedPassphrase);
    address signer = ecrecover(data, abrogateV, abrogateR, abrogateS);
    if (signer == previousOwner) owner = msg.sender;
  }
}
