// Importamos ethers desde Hardhat para interactuar con los contratos y la blockchain
const { ethers } = require("hardhat");

async function main() {
    try {
        // Direcciones de los contratos desplegados
        const contractAddress = "0xE12D8CEf088dCdE0aB0F6deD209F4aE676f4B4a3"; // Dirección del contrato ExchangeContract
        const tokenAddress = "0x498bC7E4a18AE405CA00E957C67093D0d7f75C58"; // Dirección del contrato de tokens (ERC20)
        const nftAddress = "0x7bFa2de773475CB8B410136BE9A3aE6fa152D79a"; // Dirección del contrato NFT (ERC721)

        // Obtenemos la cuenta del deployer (quien ejecuta el script)
        const [deployer] = await ethers.getSigners();
        console.log(`Usando la cuenta del deployer: ${deployer.address}`);

        // Instanciamos los contratos a partir de sus direcciones
        // ExchangeContract es el contrato principal donde ocurren las operaciones de intercambio
        const ExchangeContractFactory = await ethers.getContractFactory("ExchangeContract");
        const exchangeContract = ExchangeContractFactory.attach(contractAddress);

        // TokenContract es el contrato ERC20 para interactuar con los tokens
        const TokenContractFactory = await ethers.getContractFactory("TokenContract");
        const tokenContract = TokenContractFactory.attach(tokenAddress);

        // NFTContract es el contrato ERC721 para interactuar con los NFTs
        const NFTContractFactory = await ethers.getContractFactory("NFTContract");
        const nftContract = NFTContractFactory.attach(nftAddress);

        // **Paso 1: Verificar el balance de tokens en el contrato ExchangeContract**
        // Consultamos el balance de tokens ERC20 que tiene el contrato ExchangeContract
        const contractTokenBalance = await tokenContract.balanceOf(contractAddress);
        console.log(`El balance actual de tokens en el contrato ExchangeContract es: ${contractTokenBalance.toString()}`);

        // **Paso 2: Transferir tokens al contrato si es necesario**
        const amountToTransfer = 300n; // Cantidad de tokens que quiero que tenga el CONTRATO (en formato BigInt)
        if (contractTokenBalance < amountToTransfer) {
            // Si el balance del contrato es menor al requerido, verificamos el balance del deployer
            const deployerTokenBalance = await tokenContract.balanceOf(deployer.address);
            console.log(`El balance actual de tokens en la cuenta del deployer es: ${deployerTokenBalance.toString()}`);

            // Si el deployer no tiene suficientes tokens, lanzamos un error
            if (deployerTokenBalance < amountToTransfer) {
                throw new Error("No hay suficientes tokens en la cuenta del deployer para transferir al contrato.");
            }

            // Transferimos los tokens desde el deployer al contrato ExchangeContract
            console.log(`Transfiriendo ${amountToTransfer.toString()} tokens al contrato ExchangeContract...`);
            const transferTx = await tokenContract.transfer(contractAddress, amountToTransfer);
            await transferTx.wait(); // Esperamos a que la transacción sea confirmada
            console.log("Tokens transferidos exitosamente al contrato ExchangeContract.");
        } else {
            console.log("El contrato ExchangeContract ya tiene suficientes tokens.");
        }

        // **Paso 3: Registrar al inversor**
        // Configuramos los datos del inversor que será registrado
        const investorAddress = "0x60850CDE6Be895a5a355583CEA1F8668Ec73A2ED"; // Dirección del inversor
        const rewardTokens = 100n; // Cantidad de tokens de recompensa que recibirá el inversor (en formato BigInt)
        const isType1 = false; // Tipo de inversor: false significa que es tipo 2

        // Registramos al inversor en el contrato ExchangeContract
        console.log(`Registrando al inversor ${investorAddress} con ${rewardTokens.toString()} tokens y tipo ${isType1 ? "1" : "2"}...`);
        const registerTx = await exchangeContract.registerInvestor(investorAddress, rewardTokens, isType1);
        await registerTx.wait(); // Esperamos a que la transacción sea confirmada
        console.log(`Inversor ${investorAddress} registrado exitosamente.`);

        // Verificamos los detalles del inversor registrado
        const investor = await exchangeContract.investors(investorAddress);
        console.log(`Detalles del inversor registrado: ${JSON.stringify({
            rewardTokens: investor.rewardTokens.toString(),
            isType1: investor.isType1
        })}`);

        // **Paso 4: Transferir NFTs al contrato ExchangeContract (solo si el inversor es tipo 2)**
        if (!isType1) { // Solo ejecutamos esta sección si el inversor es tipo 2
            const nftIds = [3]; // IDs de los NFTs que deseamos transferir al CONTRATO!!!
            for (const nftId of nftIds) {
                // Verificamos quién es el propietario actual del NFT
                const currentOwner = await nftContract.ownerOf(nftId);
                if (currentOwner.toLowerCase() === contractAddress.toLowerCase()) {
                    console.log(`El NFT con ID ${nftId} ya está en posesión del contrato ExchangeContract.`);
                    continue; // Si el contrato ya es el propietario, pasamos al siguiente NFT
                }

                // Si el deployer no es el propietario del NFT, lanzamos un error
                if (currentOwner.toLowerCase() !== deployer.address.toLowerCase()) {
                    throw new Error(
                        `El NFT con ID ${nftId} no pertenece ni al deployer ni al contrato ExchangeContract. Propietario actual: ${currentOwner}`
                    );
                }

                // Aprobamos al contrato ExchangeContract para manejar el NFT
                console.log(`Aprobando al contrato ExchangeContract para manejar el NFT con ID ${nftId}...`);
                const approveTx = await nftContract.approve(contractAddress, nftId);
                await approveTx.wait(); // Esperamos a que la transacción sea confirmada
                console.log(`Contrato ExchangeContract aprobado para manejar el NFT con ID ${nftId}.`);

                // Transferimos el NFT al contrato ExchangeContract
                console.log(`Transfiriendo NFT con ID ${nftId} al contrato ExchangeContract...`);
                const transferNFTTx = await nftContract["safeTransferFrom(address,address,uint256)"](
                    deployer.address,
                    contractAddress,
                    nftId
                );
                await transferNFTTx.wait(); // Esperamos a que la transacción sea confirmada
                console.log(`NFT con ID ${nftId} transferido exitosamente al contrato ExchangeContract.`);

                // Verificamos que el NFT se haya registrado correctamente en el contrato
                const availableNFTs = await exchangeContract.getAvailableNFTs();
                console.log(`NFTs disponibles en el contrato ExchangeContract: ${availableNFTs.map(id => id.toString())}`);
                if (!availableNFTs.map(id => id.toString()).includes(nftId.toString())) {
                    throw new Error(`El NFT con ID ${nftId} no se registró correctamente en availableNFTs.`);
                }
            }
        } else {
            console.log("El inversor es de tipo 1, no se requieren NFTs.");
        }

        // **Paso 5: Reclamar recompensas para el inversor**
        console.log(`Reclamando recompensas para el inversor ${investorAddress}...`);
        const claimTx = await exchangeContract.claimRewards(investorAddress);
        await claimTx.wait(); // Esperamos a que la transacción sea confirmada
        console.log(`Recompensas reclamadas exitosamente para el inversor ${investorAddress}.`);

        // Verificamos que el NFT se haya transferido correctamente al inversor (solo si era tipo 2)
        if (!isType1) {
            const nftIds = [3]; // IDs de los NFTs transferidos (CAMBIAR SI ES NECESARIO)
            const newOwner = await nftContract.ownerOf(nftIds[3]); // CAMBIAR SI ES NECESARIO EL ID DEL NFT
            if (newOwner.toLowerCase() !== investorAddress.toLowerCase()) {
                throw new Error(`El NFT con ID ${nftIds[3]} no fue transferido correctamente al inversor.`);
            }
            console.log(`El NFT con ID ${nftIds[3]} ahora pertenece al inversor ${investorAddress}.`);
        }
    } catch (error) {
        // Capturamos y mostramos cualquier error que ocurra durante la ejecución
        console.error("Error:", error.message || error);
        process.exit(1); // Terminamos el proceso con un código de error
    }
}

// Llamamos a la función principal
main();

