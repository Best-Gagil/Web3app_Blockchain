// deploy.js
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const exchangeContractModule4 = buildModule("exchangeContractModule4", (m4) => {
    // Asume que TokenContract y NFTContract ya están desplegados
    const tokenAddress = "0x498bC7E4a18AE405CA00E957C67093D0d7f75C58"; // Reemplaza con la dirección de tu contrato de tokens
    const nftAddress = "0x7bFa2de773475CB8B410136BE9A3aE6fa152D79a"; // Reemplaza con la dirección de tu contrato de NFTs

    // Despliega el contrato ExchangeContract
    const exchangeContract4 = m4.contract("ExchangeContract", [tokenAddress, nftAddress]);

    return { exchangeContract4 };
});

module.exports = exchangeContractModule4;
