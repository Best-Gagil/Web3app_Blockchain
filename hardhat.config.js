/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox"); //importa el plugin de hardhat-toolbox

//Ensure you configuration variables are set before executing the script
const {vars} = require("hardhat/config");
const INFURA_API_KEY = vars.get("INFURA_API_KEY"); //obtiene la variable de entorno INFURA_API_KEY (INFURA GET KEY)
const SEPOLIA_PRIVATE_KEY = vars.get("SEPOLIA_PRIVATE_KEY"); //obtiene la variable de entorno SEPOLIA_PRIVATE_KEY (METAMASK)

module.exports = {
  solidity: "0.8.27",
  defaultNetwork: "localhost",

  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`, //url de la red de sepolia(cambiar si es necesario)
      accounts: [SEPOLIA_PRIVATE_KEY],
    },

  },

};
