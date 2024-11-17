// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz para interactuar con el contrato CCIP destino
interface ICCIPDestination {
    function flag() external view returns (uint256);
    function getLastReceivedMessageDetails()
        external
        view
        returns (
            bytes32 messageId,
            string memory text,
            address tokenAddress,
            uint256 tokenAmount
        );
}

// Interfaz para interactuar con el contrato DAO
interface IDAOVoting {
    function registerMemberByManualInput(address member) external;
}

contract Orchestrator {
    ICCIPDestination public ccipContract;
    IDAOVoting public daoContract;

    // Almacena la dirección convertida manualmente
    address public convertedAddress;

    // Constructor para inicializar los contratos externos
    constructor(address _ccipContractAddress, address _daoContractAddress) {
        ccipContract = ICCIPDestination(_ccipContractAddress);
        daoContract = IDAOVoting(_daoContractAddress);
    }

    // Función para consultar la bandera en tiempo real (solo lectura)
    function queryFlag() external view returns (uint256) {
        return ccipContract.flag();
    }

    // Función para consultar el último mensaje en tiempo real (solo lectura)
    function queryLastMessage() external view returns (string memory) {
        (, string memory text, , ) = ccipContract.getLastReceivedMessageDetails();
        return text;
    }

    // Función para convertir el mensaje (string) en una dirección manualmente
    function convertMessageToAddress(string calldata message) external {
        require(bytes(message).length == 42, "Formato de direccion invalido");
        bytes memory tempBytes = bytes(message);
        uint160 addressValue = 0;

        for (uint256 i = 2; i < 42; i++) {
            uint8 digit;
            uint8 asciiValue = uint8(tempBytes[i]);

            if (asciiValue >= 48 && asciiValue <= 57) {
                digit = asciiValue - 48;
            } else if (asciiValue >= 97 && asciiValue <= 102) {
                digit = asciiValue - 87;
            } else {
                revert("Caracter invalido en la direccion");
            }

            addressValue = addressValue * 16 + digit;
        }

        convertedAddress = address(addressValue);
    }

    // Función para registrar la dirección convertida en la DAO
    function registerConvertedAddress() external {
        require(convertedAddress != address(0), "No hay direccion convertida");
        daoContract.registerMemberByManualInput(convertedAddress);
    }
}
