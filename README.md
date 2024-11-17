![Asset 3](https://github.com/user-attachments/assets/67f82923-615d-472f-9294-61fd9f37c066)


InifinteDAO 

Case of use: unites users from multiple blockchains into a single decentralized organization. Powered by 
@chainlink CCIP, breaking barriers for a truly interoperable and inclusive DAO

Process to deploy SC's:
1. SourceCCIP
2. DestinationCCIP

It´s necesary to follow Chainlink documentation to setup SourceCCIP and DestinationCCIP

3. MainDao 
4. ProxySource, uses SourceCCIP and MainDao address to deploy

   Users from arbitrum can to interact directly to MainDao to register user, create proposal, vote proposal, close proposal.
   MainDao needs Links tokens to execute porposal execution action.

   Users from others blockchain can to register to the Dao via CCIP capabilities

   
Project created by @simonxpe for ETHGlobal Bangkok 2024 hackathon
