var ERC20Token               = artifacts.require("./ERC20Token.sol")
var SimpleToken              = artifacts.require("./SimpleToken.sol")
var Trustee                  = artifacts.require("./Trustee.sol")
var TokenSale                = artifacts.require("./TokenSale.sol")
var ConvertLib               = artifacts.require("./ConvertLib.sol");
var CabCoin                  = artifacts.require("./CabCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, CabCoin);
  deployer.deploy(CabCoin);
};
