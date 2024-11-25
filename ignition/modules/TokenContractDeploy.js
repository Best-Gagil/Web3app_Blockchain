const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenContractModule = buildModule("TokenContractModule", (m) => {
    const TokenContract = m.contract("TokenContract"); // Asegúrate de que el nombre coincide con el de tu contrato

    return { TokenContract };
});

// Función de despliegue sin parámetros, ya que el constructor no los requiere
TokenContractModule.deploy = async function () {
    const { TokenContract } = this;

    // Despliega el contrato sin parámetros
    const tokenInstance = await TokenContract.deploy();
    console.log("Token deployed to:", tokenInstance.address);

    return tokenInstance;
};

module.exports = TokenContractModule;

