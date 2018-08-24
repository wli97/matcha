# Matcha
Insurance Blockchain for Claims Processing

## Introduction
### Usage:

Matcha is a decentralized app (dapp) for insurance claims, aiming to eliminate fraud and ultimately reduce the premium for users. With Matcha, you get:

- User-friendly portal app with features that allow direct interaction with the bio-system of insurance claims.
- User specific access/rights to the shared system of data among one or multiple institutions.
- Immutability and anti-tamper property for claims submitted.
- Allow each party, from client to government, to be able to verify the well functioning of the system.

### The Idea

The general idea is fairly straightforward: to have a contract protocol that everyone can see and agree with. Since this protocol is transparent, no one can change the interaction with the database, which itself is also permission-ed transparent. In this way, no single party can tamper past data and everyone has to operate as the contract dictates. Therefore, we need a contract that specifies the rights for each type of users as well as the functions allowed for each user. From there, the blockchain governed by this contract will store claim requests as encrypted data.

An ideal contract would involve the following major steps:
- Store the user type of each address where the address is assumed to be unique for each person (implemented outside of Matcha).
- Store the requests made by an user address without possibility of removal (read, append only).
- Getter and adder for users and requests. Getter allowed for relevant users and setter allowed for banks/government.
-  Validation allowed for involved agents, with distinct status code to visualize the flow.
-  Encrypted requests and signature so that only the relevant parties can access the information. (Hard).
-  Finally payments from designated institution are appended to requests.

### How to start the app

1. Install Ganache on your laptop to host a blockchain.
2. Install a conda/virtualenv with python3, install web3 on this environment.
3. Deploy Entity.sol using "truffle test" or "truffle compile --reset"
4. Find the address of contract on Ganache and replace it with the contractAddress on app.py if different
5. If the json file path is different from the compiled file in build/contracts, change it too.
6. Fix the HttpProvider to the correct port.
7. runApp() from server.r.



## Backend
BackEnd

The backend of Matcha is composed of a contract running on ethereum blockchain and a server-end on the shinyapp that connects to the blockchain.


### Contract on Blockchain

Ethereum Blockchain is used to simulate a fully private-permission-ed blockchain like R3. The reason to use Ethereum is for its easy-to-develop, complete dev-tools and supportive community.

It is ideal for prototype building to showcase the power of an otherwise fully secure blockchain system. 

Solidity is the official development language for contracts running on Ethereum. A contract is a piece of pre-set rules that people have to agree with in order to exploit its whole functionalities.

Here is the start of Matcha contract called Entity.
### Structures in memory

Public addresses and storage structures define how different parties operate. User, Request and Validation are three objects recognized and stored by Entity.

    User: is used to keep track of addresses recognized by Matcha, which are given an usertype(insurance companies, police, repair agent, clients), institution code (TDI, Intact, Aviva, etc.), and other fields relevant to a party on this contract.
    Request: is used as the official structure of any request clients claim. It stores the time it is published, the addresses of requested validation parties, claimType, status of completion, institution requested, amount requested/paid as well as a field for any detail the different parties want to append to this request.
    Validation: is used to as a stack of tasks assigned to this service provider address. It has the address of the client as well as the index on the request array of the client in able to find the assigned request.

### Mapping as key to memory

Mapping is the way to access the data related to an address or an agency. It acts as a dictionary/hashmap, outputs data given an input of address or integer.

    userInfo: to access user type and other user specific profile.
    requests: to access the array of requests a client had submitted.
    validations: to access the array of requests an agent address has to validate.

### Event

Events are particularly useful for event-listening-handling model. When triggered, the contract will emit your specified event to the logs. Ideally, this can be used for server nodes to listen for any new validation targeting them. However, for this to work, we need to assume agents will listen events according to protocols.

In Matcha, events can be used when a new claim is requested\modified and when payment is sent.


### Contract functions

Contract's functions act as API/Methods for participants to communicate and interact with the contract.

In Matcha, we have:

fallback(): to prevent ether loss if someone sends value to contract without any action, the contract catchs $.

setter/getter: to allow users to use data stored according to their user type and access rights.

kill(): to kill the contract, this is for development purpose and should be removed for real use cases.

openStatus: to allow clients to open their insurance companies transitions. When open, another insurance                company is allowed to become the new institution of the client and gains access to his requests records.

requestClaim: to initiate a new request, by client or repair agent.

validate: to validate the request claim validity true/false. Append justification.

payClaim: for banks to pay the claim amount to the client, append paid amount and justification.

concat: a helper function for string concatenation since solidity does not have one.


Notice that most functions have a view/payable/pure modifier, these specify the nature of the function to be whether view only, modifying data, or for internal use only. Functions also have revert() to verify the access rights of the person behind a function call (address). This is to simulate the interactions of a permission-ed blockchain where participants' identity and access are strictly designated.


### Design decisions

Since requests from clients are valuable and give insights on the nature of the clients, they are stored permanently on the blockchain. For security reasons, there must be some guarding points/measure to make sure a client does not (or incentivized not to) spam claim requests. Storage is costly on blockchain, so only store important data and carry minimally necessary operations on blockchain, ie. do as much as possible and only deliver final transactions to blockchain.

Similarly, validations are implemented in a way that it keeps the stack smallest possible through in-place swaps. Since we can find client's requests anyways along with the justification of validation, I feel there is no need to store past claims for non-client agents.

In addition, to minimize data size on requests, I chose to use numbers to represent claim type and status. The exact status definition can be found on source code. 



### Web3 library and server-blockchain communication

Web3 is a tool to communicate with blockchain and shapes bytecodes into easy-to-use objects. It also computes the correct hexcode for transactions to the contract. Extremely powerful.

init(m.e) is the function to establish global variables and connection parameters, which happens at the beginning of app loading. Notice you need to have a compiled ABI/Json object of the contract stored so that web3 knows the structure of Matcha contract without spending any cost. If this object is not the exact copy of the real contract, function calls will fail.

Also notice the addUser function. In order to modify data, it must be in form of transactions since there is a cost related to data modification on blockchain. So the code has to build a raw transaction and sign it with private key so that your transaction is secure and publishable. This is required if infura is the HTTPProvider since Infura is a hosted node that should not store private keys.


Now, to establish communication with blockchain, I need to either set up a node on blockchain or use a hosted node like Infura or use a virtual blockchain by Ganache. The default option is Ganache on Drogon.

Ganache can be found in the Blockchain folder, or you can install it yourself. It provides a list of address and private key. Change these global constants in the code if yours are different.

Infura is the way to have a hosted node on testnet. You need an account first and then use the provided API through project creation. The link is https://infura.io/


## FrontEnd
### Four different UI depending on the login

The app consists of 4 possible views: client, repair, police, insurance companies.
Client App

Client app has the function to submit a new claim request and to review client's own past requests. The new claim request can be done for auto or residential where the form adapts to the corresponding format.

Client specifies who can validate his claim, which should be used as an incentive of speed (validations make the claim faster and more trustworthy). The claim together with info is sent to requestClaim() of the contract with status:

Status 0 - No validation, the insurance claim agents have to determine whether to pay (slow).

Status 1 - Police validation only, the claim index is added to police address's stack of work.

Status 2 - Repair validation only, similar to above.

Status 3 - Police and Repair validation, added to both stacks.

Error prompts when the client's inputs are illogical (future accident date, smaller than deductible amount and higher than liability amount etc.). For this prototype at this moment, the app does not search for client's policy plan but this can be implemented for the TD version app, after all, this UI is for TD-clients. The login should then send the client's profile and policies to the app so that the new claim request can detect conformity.

Another feature to improve is a selector for repair agent to validate. This can be done through a dropdown search or a map search.

### Repair/Police App

These intermediaries have the rights to help validate requests. A possible incentive can be that for each validation they receive an amount of reward.

Their validation and justification are appended to the request on blockchain with status:

4 - Repair completed, now waiting for police

5 - Police completed, now waiting for repair

6 - Validation phase completed

7 - Police denied request

8 - Repair denied request

In addition, repair has the possibility to make a request on client's behalf. This feature is not yet implemented, a possible way is to give the garage right to modify claim type and claim amount if these are 0 from client.

Police/Insurance companies can potentially set the industry average so that if a request is fully validated and below a reasonable amount by industry average for its claim type. The claim is immediately paid through smart contract.

### Insurance company App

Claims agent from companies can view the current requests to pay/deny. Agent determines the amount to pay and whether to pay.

He/she can also search a specific client for his historical requests through search client, if this client (address) is not with the current company searcher, nothing will appear. If the address is not a client, nothing will appear.

Potentially, he/she can also fund money to the contract so that it can pay immediately clients who passed all criterion for automated payment.

This portal provides the final append for a claim request with status:

9 - Request denied, payment not sent.

10 - Request accepted, payment sent with updated Amount field.

For 10, the amount sent is in Ether, so ideally in a private blockchain, some ways of translating cryptocurrency to real money is implemented. In fact, companies would probably prefer pay with another system other than the blockchain with cryptocurrency. But this is beyond the purpose of this prototype.

### Server - Backend of Frontend

A general server.R communicates with ui.R by updating the views for "page" and "login".

At the start of the app, login is the main view of the page until successful authentication. This part is done very badly and insecurely in the prototype since every client accounts are place holders. 

After login, the login.R script will link the user to the correct account by updating the field of ID (1-4), public address as well as the private key of logger. This field is named USER.

When the app is LOGGED by true, this will bring down "login" and show "page". Depending on credential, this can be either of the 4 UI shown before.

Different script based on the login will be loaded. Which will become the main view. In practice, different UI app should be totally isolated with different binary install file. All views are in the prototype to facilitate file exploration.

bank.R police.R, garage.R, client.R are the 4 different scripts for the 4 UI. util.R and c.css are also used for repeated view pattern and useful functions.
Structure of a view-server script in Matcha

All 4 files start with an update function which updates the requests/tasks from the blockchain at the start of the app. For clients, it will sort to current and past requests.

Then, there is the UI section which builds the uiOutput("page") of ui.R.

Then, there is the server section which are a list of observe-reactive functions which manipulates with user inputs. They also call functions in app.py.


Technical details

The list of requests are updated using an update function in R which retrieve all requests for the clients one by one. This might be improved with a better algorithm for efficiency.

Repair should be given the rights to modify claim type and claim amount if claim type is empty. Luckily, the field of description records client's initial request so repair agent cannot be too ridiculous with the amount.

The list itself is updated with shinymaterial's update_field. Since shiny material drop down does not provide a scroll bar, this might be an issue for people who had a lot of requests.

Important: there should be a way to stop people from making many requests within a short period of time to eliminate unnecessary overhead and cost. At this moment, this is not implemented.
