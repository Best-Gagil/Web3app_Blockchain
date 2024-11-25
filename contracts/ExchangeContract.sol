// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

// Importación de los contratos externos TokenContract y NFTContract
// Estos contratos representan el token ERC20 y el token ERC721 (NFT) que se usarán en este contrato.
import "./TokenContract.sol";
import "./NFTContract.sol";

// Declaración del contrato ExchangeContract
contract ExchangeContract {
    // Referencia al contrato de tokens (TokenContract)
    TokenContract public token;
    // Referencia al contrato de NFTs (NFTContract)
    NFTContract public nft;

    // Estructura que representa a un inversor
    struct Investor {
        uint256 rewardTokens; // Cantidad de tokens de recompensa asignados al inversor
        bool isType1; // Tipo de inversor (true para inversor tipo 1, false para tipo 2)
    }

    // Mapeo que asocia una dirección (inversor) con su información (estructura Investor)
    mapping(address => Investor) public investors;

    // Arreglo que almacena los IDs de los NFTs disponibles en el contrato
    uint256[] public availableNFTs;

    // Constructor del contrato
    // Recibe las direcciones de los contratos de tokens y NFTs y las asigna a las variables correspondientes
    constructor(TokenContract _token, NFTContract _nft) {
        token = _token; // Inicializa la referencia al contrato de tokens
        nft = _nft; // Inicializa la referencia al contrato de NFTs
    }

    // Evento que se emite cuando el contrato recibe un NFT
    event NFTReceived(address indexed operator, address indexed from, uint256 tokenId, bytes data);

    // Función que se ejecuta automáticamente cuando el contrato recibe un NFT (ERC721)
    // Esta función es necesaria para cumplir con la interfaz ERC721Receiver
    function onERC721Received(
        address operator, // Dirección que ejecutó la transferencia del NFT
        address from, // Dirección de origen del NFT
        uint256 tokenId, // ID del NFT transferido
        bytes calldata data // Datos adicionales (si los hubiera)
    ) external returns (bytes4) {
        // Agregar el ID del NFT recibido al arreglo de NFTs disponibles
        availableNFTs.push(tokenId);

        // Emitir un evento indicando que se recibió un NFT
        emit NFTReceived(operator, from, tokenId, data);

        // Retornar el selector de la función para confirmar la recepción del NFT
        return this.onERC721Received.selector;
    }

    // Función para que un usuario deposite un NFT en el contrato
    function depositNFT(uint256 tokenId) external {
        // Transferir el NFT desde el usuario al contrato
        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        // Agregar el ID del NFT al arreglo de NFTs disponibles
        availableNFTs.push(tokenId);
    }

    // Función para que un inversor reclame sus recompensas
    function claimRewards(address _investor) external {
        // Obtener la información del inversor del mapeo
        Investor storage investor = investors[_investor];

        // Verificar que el inversor tenga recompensas pendientes
        require(investor.rewardTokens > 0, "No hay recompensas para reclamar");

        // Si el inversor es de tipo 1
        if (investor.isType1) {
            // Transferir los tokens de recompensa al inversor
            token.transfer(_investor, investor.rewardTokens);
        } else {
            // Si el inversor es de tipo 2, debe recibir un NFT además de los tokens

            // Verificar que haya NFTs disponibles en el contrato
            require(availableNFTs.length > 0, "No hay NFTs disponibles para reclamar");

            // Obtener el ID del último NFT disponible
            uint256 tokenId = availableNFTs[availableNFTs.length - 1];

            // Eliminar el último NFT del arreglo (pop elimina el último elemento)
            availableNFTs.pop();

            // Transferir los tokens de recompensa al inversor
            token.transfer(_investor, investor.rewardTokens);

            // Transferir el NFT al inversor
            nft.safeTransferFrom(address(this), _investor, tokenId);
        }

        // Establecer las recompensas del inversor a 0 (ya fueron reclamadas)
        investor.rewardTokens = 0;
    }

    // Función para registrar un nuevo inversor
    function registerInvestor(address _investor, uint256 _rewardTokens, bool _isType1) external {
        // Asignar la información del inversor al mapeo
        investors[_investor] = Investor({
            rewardTokens: _rewardTokens, // Cantidad de tokens de recompensa asignados
            isType1: _isType1 // Tipo de inversor
        });
    }

    // Función para obtener todos los NFTs disponibles en el contrato
    // Devuelve un arreglo con los IDs de los NFTs disponibles
    function getAvailableNFTs() external view returns (uint256[] memory) {
        return availableNFTs;
    }
}

