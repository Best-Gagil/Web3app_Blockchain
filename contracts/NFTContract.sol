// SPDX-License-Identifier: MIT
// Este contrato es compatible con OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

// Importa el contrato ERC721 estándar de OpenZeppelin
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Importa la extensión ERC721URIStorage que permite almacenar URIs de metadatos
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// Importa el contrato Ownable de OpenZeppelin, que permite la gestión de la propiedad del contrato
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Contrato NFT que hereda de ERC721, ERC721URIStorage y Ownable
contract NFTContract is ERC721, ERC721URIStorage, Ownable {
    // ID del próximo token a acuñar
    uint256 private _nextTokenId;

    // Constructor del contrato que inicializa el nombre y símbolo del token
    constructor()
        ERC721("MyToken", "MTK") // Inicializa el ERC721 con nombre "MyToken" y símbolo "MTK"
        Ownable(msg.sender) // Establece al creador del contrato como propietario
    {}

    // Función para acuñar un nuevo NFT de manera segura
    function safeMint(string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++; // Asigna el ID del nuevo token y lo incrementa
        _safeMint(msg.sender, tokenId); // Acuña el NFT y lo asigna al propietario (msg.sender)
        _setTokenURI(tokenId, uri); // Establece la URI del token, que apunta a sus metadatos
    }

    // Las siguientes funciones son sobreescrituras requeridas por Solidity para manejar la lógica de ERC721 y ERC721URIStorage.

    // Función para obtener la URI del token
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage) // Indica que está sobreescribiendo ambas funciones
        returns (string memory)
    {
        return super.tokenURI(tokenId); // Llama a la función tokenURI de la superclase
    }

    // Función para comprobar si el contrato soporta una interfaz específica
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage) // Indica que está sobreescribiendo ambas funciones
        returns (bool)
    {
        return super.supportsInterface(interfaceId); // Llama a la función supportsInterface de la superclase
    }

    function transferNFT(address from, address to, uint256 tokenId) external {
    safeTransferFrom(from, to, tokenId);
}

}
