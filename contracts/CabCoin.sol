pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract MyMath {
  using SafeMath for uint256;

    uint constant DAY_IN_SECONDS = 86400;
    uint constant BASE = 1000000000000000000;
    uint constant preIcoPrice = 4101;
    uint constant icoPrice = 2255;

    function mulByFraction(uint256 number, uint256 numerator, uint256 denominator) internal returns (uint256) {
        return div(mul(number, numerator), denominator);
    }

    // presale volume bonus calculation
    function presaleVolumeBonus(uint256 price) internal returns (uint256) {

        // preCTX > ETH
        uint256 val = div(price, preIcoPrice);

        if(val >= 100 * BASE) return add(price, price * 1/20); // 5%
        if(val >= 50 * BASE) return add(price, price * 3/100); // 3%
        if(val >= 20 * BASE) return add(price, price * 1/50);  // 2%

        return price;
    }

	// volume bonus calculation for CabCoin
    function volumeBonus(uint256 etherValue) internal returns (uint256) {
                      // 1000000000000000000
        if(etherValue >= 1000000000000000000000) return 20;// +15% tokens
        if(etherValue >=  500000000000000000000) return 15; // +10% tokens
        if(etherValue >=  300000000000000000000) return 12;  // +7% tokens
        if(etherValue >=  100000000000000000000) return 10;  // +5% tokens
        if(etherValue >=   50000000000000000000) return 8;   // +3% tokens
        if(etherValue >=   20000000000000000000) return 5;   // +2% tokens
        if(etherValue >=   10000000000000000000) return 2;   // +2% tokens

        return 0;
    }

	// date bonus calculation for CabCoin
    function dateBonus(uint startIco) internal returns (uint256) {

        // day from ICO start
        uint daysFromStart = (now - startIco) / DAY_IN_SECONDS + 1;

        if(daysFromStart <= 7) return 35; // +15% tokens
        if(daysFromStart <= 14) return 30; // +10% tokens
        if(daysFromStart <= 21) return 25; // +10% tokens
        if(daysFromStart <= 28) return 20;  // +5% tokens
        if(daysFromStart <= 35) return 10;  // +5% tokens
        if(daysFromStart <= 42) return 0;  // +0% tokens

		    // no discount
        return 0;
    }

}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.

// contract CabCoinToken is StandardToken, SafeMath, Ownable {
contract CabCoinToken is StandardToken, MyMath, Ownable {

    /*
     * Token meta data
     */
    string public constant name = "CabCoin";
    string public constant symbol = "MCY";
    uint public constant decimals = 18;

    mapping (address => uint256) balances;
    mapping (address => bool) ownerAppended;
    mapping (address => mapping (address => uint256)) allowed;
    // uint256 public totalSupply;
    address[] public owners;

    // total supply

    address public icoContract = 0x0;
    /*
     * Modifiers
     */

    modifier onlyIcoContract() {
        // only ICO contract is allowed to proceed
        require(msg.sender == icoContract);
        _;
    }

    /*
     * Contract functions
     */

    /// @dev Contract is needed in icoContract address
    /// @param _icoContract Address of account which will be mint tokens
    function CabCoinToken(address _icoContract) {
        assert(_icoContract != 0x0);
        icoContract = _icoContract;
    }

    /// @dev Burns tokens from address. It's can be applied by account with address this.icoContract
    /// @param _from Address of account, from which will be burned tokens
    /// @param _value Amount of tokens, that will be burned
    function burnTokens(address _from, uint _value) onlyIcoContract {
        assert(_from != 0x0);
        require(_value > 0);

        balances[_from] = sub(balances[_from], _value);
    }

    /// @dev Adds tokens to address. It's can be applied by account with address this.icoContract
    /// @param _to Address of account to which the tokens will pass
    /// @param _value Amount of tokens
    function emitTokens(address _to, uint _value) onlyIcoContract {
        assert(_to != 0x0);
        require(_value > 0);

        balances[_to] = add(balances[_to], _value);

        if(!ownerAppended[_to]) {
            ownerAppended[_to] = true;
            owners.push(_to);
        }

    }

    function getOwner(uint index) constant returns (address, uint256) {
        return (owners[index], balances[owners[index]]);
    }

    function getOwnerCount() constant returns (uint) {
        return owners.length;
    }

}
