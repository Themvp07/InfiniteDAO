Process to deploy SC's:
1. SourceCCIP
2. DestinationCCIP

It´s necesary to follow Chainlink documentation to setup SourceCCIP and DestinationCCIP

3. MainDao 
4. ProxySource, uses SourceCCIP and MainDao address to deploy

   Users from arbitrum can to interact directly to MainDao to register user, create proposal, vote proposal, close proposal.
   MainDao needs Links tokens to execute porposal execution action.

   Users from others blockchain can to register to the Dao via CCIP capabilities

   
