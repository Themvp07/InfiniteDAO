// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz del token LINK
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DAOVoting {
    // Dirección del contrato de token LINK en Sepolia
    IERC20 public linkToken = IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    // Estado de una propuesta
    enum ProposalStatus { Active, Closed, Executed }

    // Estructura de propuesta
    struct Proposal {
        address creator;
        address payable recipient;
        uint256 amount;
        string description; // Nueva descripción de la propuesta
        uint256 votesFor;
        uint256 votesAgainst;
        ProposalStatus status;
        mapping(address => bool) voters;
    }

    // Almacenar usuarios y propuestas
    mapping(address => bool) public members;
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    // Modificadores
    modifier onlyMember() {
        require(members[msg.sender], "No eres un miembro registrado.");
        _;
    }

    modifier proposalExists(uint256 proposalId) {
        require(proposalId < proposalCount, "La propuesta no existe.");
        _;
    }

    modifier proposalIsActive(uint256 proposalId) {
        require(proposals[proposalId].status == ProposalStatus.Active, "La propuesta no esta activa.");
        _;
    }

    // Eventos
    event NewProposal(uint256 indexed proposalId, address indexed creator, address recipient, uint256 amount, string description);
    event Vote(uint256 indexed proposalId, address indexed voter, bool inFavor);
    event ProposalClosed(uint256 indexed proposalId, bool approved);
    event ProposalExecuted(uint256 indexed proposalId, address recipient, uint256 amount);

    // Registrar un usuario
    function registerMember() external {
        require(!members[msg.sender], "Ya estas registrado.");
        members[msg.sender] = true;
    }

    // Crear una propuesta
    function createProposal(address payable _recipient, uint256 _amount, string memory _description) external onlyMember {
        require(bytes(_description).length > 0, "La descripcion es obligatoria");

        Proposal storage newProposal = proposals[proposalCount];
        newProposal.creator = msg.sender;
        newProposal.recipient = _recipient;
        newProposal.amount = _amount;
        newProposal.description = _description;
        newProposal.status = ProposalStatus.Active;

        emit NewProposal(proposalCount, msg.sender, _recipient, _amount, _description);
        proposalCount++;
    }

    // Votar en una propuesta
    function vote(uint256 proposalId, bool inFavor) external onlyMember proposalExists(proposalId) proposalIsActive(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.voters[msg.sender], "Ya has votado en esta propuesta.");
        
        proposal.voters[msg.sender] = true;
        if (inFavor) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Vote(proposalId, msg.sender, inFavor);
    }

    // Cerrar la votación y ejecutar la propuesta automáticamente si es aprobada
    function closeAndExecuteProposal(uint256 proposalId) external onlyMember proposalExists(proposalId) proposalIsActive(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        
        // Cambiar el estado a cerrado
        proposal.status = ProposalStatus.Closed;

        bool approved = proposal.votesFor > proposal.votesAgainst;
        emit ProposalClosed(proposalId, approved);

        // Ejecutar si fue aprobada
        if (approved && linkToken.balanceOf(address(this)) >= proposal.amount) {
            proposal.status = ProposalStatus.Executed;
            linkToken.transfer(proposal.recipient, proposal.amount);

            emit ProposalExecuted(proposalId, proposal.recipient, proposal.amount);
        }
    }

    // Obtener el balance de tokens LINK en el contrato
    function getContractLinkBalance() external view returns (uint256) {
        return linkToken.balanceOf(address(this));
    }

    // Obtener el estado de una propuesta en texto
    function getProposalStatus(uint256 proposalId) external view proposalExists(proposalId) returns (string memory) {
        ProposalStatus status = proposals[proposalId].status;
        if (status == ProposalStatus.Active) return "Activa";
        if (status == ProposalStatus.Closed) return "Cerrada";
        if (status == ProposalStatus.Executed) return "Ejecutada";
        return "";
    }
}