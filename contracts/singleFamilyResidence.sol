
import "owned";

contract SingleFamilyResidence is owned {

    struct Property {
        bool exists;
        address OP;
        bytes32[] residences;
    }

    uint public price;
    mapping(bytes32 => Property) public properties;

    event Post(bytes32 rootHash, bytes32 propertyHash);

    modifier costs { if (msg.value >= price) _ }

    function residence( bytes32 rootPropertyHash, bytes32 residence, address OP, bool tip ) costs {
        address realtor = msg.sender;
        if (properties[rootPropertyHash].exists && residence != bytes32(0)) {

            // append to residence
            properties[rootPropertyHash].residences.length++;
            properties[rootPropertyHash].residences[properties[rootPropertyHash].residences.length] = residence;
            Post( rootPropertyHash, residence);
            handleTip( tip, OP );

        } else if (!properties[rootPropertyHash].exists) {

            // open house to MLS
            bytes32[] memory tmp;
            properties[rootPropertyHash] = Property( true, OP, tmp);
            Post( rootPropertyHash, bytes32(0));
            handleTip( tip, OP );
        }
    }

    function handleTip (bool tip, address OP) internal {
        if (tip && OP != address(0)) {
            OP.send( price );
        } else {
            owner.send( price );
        }
    }

    function changePrice(uint _price) onlyowner {
        price = _price;
    }
}

