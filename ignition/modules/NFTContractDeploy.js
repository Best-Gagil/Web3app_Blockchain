const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// Creamos un módulo para el despliegue del contrato NFTContract
const NFTContractModule = buildModule("NFTContractModule", (m) => {
    // Referencia al contrato NFTContract
    const NFTContract = m.contract("NFTContract"); // Asegúrate de que el nombre coincide con el de tu contrato

    return { NFTContract };
});

// Función de despliegue del contrato
NFTContractModule.deploy = async function () {
    const { NFTContract } = this;

    // Despliega el contrato sin parámetros, ya que el constructor no los requiere
    const nftInstance = await NFTContract.deploy();
    console.log("NFTContract desplegado en la dirección:", nftInstance.address);

    return nftInstance;
};

module.exports = NFTContractModule;
