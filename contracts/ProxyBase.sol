// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz para interactuar con el contrato CCIP de origen
interface ICCIPOrigin {
    function sendMessagePayLINK(
        uint64 destinationChainSelector,
        address receiver,
        string calldata text,
        address token,
        uint256 amount
    ) external returns (bytes32);
}

// Interfaz para interactuar con los tokens ERC20
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract ProxyBase {
    address public immutable ccipOriginAddress; // Dirección del contrato CCIP de origen
    address public constant linkToken = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410; // Dirección del token LINK
    address public constant otherToken = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e; // Dirección del otro token

    uint64 public constant destinationChainSelector = 3478487238524512106; // Selector de la red de destino (fijo)
    address public constant receiver = 0x712c351D8757Ed56DB3EFCA35e6B1378A4e056c7; // Dirección del receptor (fija)
    uint256 public constant amount = 500000000000000; // Cantidad fija de tokens (500000000000000 wei)

    // Registro de direcciones enviadas
    mapping(address => bool) public registeredAddresses;

    // Constructor para inicializar la dirección del contrato CCIP de origen
    constructor(address _ccipOriginAddress) {
        require(_ccipOriginAddress != address(0), "Invalid CCIP origin address");
        ccipOriginAddress = _ccipOriginAddress;
    }

    // Función para registrar una dirección
    function registerAddress(address newAddress) external {
        require(newAddress != address(0), "Invalid address");
        require(!registeredAddresses[newAddress], "Address already registered");

        // Marcar como registrada
        registeredAddresses[newAddress] = true;

        // Convertir la dirección en texto para el mensaje
        string memory messageText = _addressToString(newAddress);

        // Llamar al contrato CCIP de origen
        ICCIPOrigin(ccipOriginAddress).sendMessagePayLINK(
            destinationChainSelector,
            receiver,
            messageText,
            otherToken,
            amount
        );
    }

    // Función para consultar los balances de LINK y el otro token en el contrato CCIP de origen
    function getBalances() external view returns (uint256 linkBalance, uint256 otherTokenBalance) {
        linkBalance = IERC20(linkToken).balanceOf(ccipOriginAddress);
        otherTokenBalance = IERC20(otherToken).balanceOf(ccipOriginAddress);
    }

    // Convertir una dirección en texto
    function _addressToString(address _address) private pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);

        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}