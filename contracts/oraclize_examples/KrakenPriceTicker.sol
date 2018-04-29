/*
   Kraken-based ETH/XBT price ticker

   This contract keeps in storage an updated ETH/XBT price,
   which is updated every ~60 seconds.

   Taken from Oraclize's git repo for Educational Purposes
*/

pragma solidity ^0.4.8;
import "../library/Oraclise.sol";

contract KrakenPriceTicker is usingOraclize {

    string public ETHXBT;

    event newOraclizeQuery(string description);
    event newKrakenPriceTicker(string price);


    function KrakenPriceTicker(address _oraclizeAddressResolver) {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
        OAR = OraclizeAddrResolverI(_oraclizeAddressResolver);
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        ETHXBT = result;
        newKrakenPriceTicker(ETHXBT);
        update();
    }

    function update() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }

}