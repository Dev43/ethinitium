https://plasma.io/plasma.pdf
https://medium.com/applicature/what-is-plasma-and-how-does-it-work-15641c95825f
https://blog.gridplus.io/bridges-plasma-and-utxo-tokens-e1244c8b1824
https://blog.gridplus.io/plasma-and-the-internet-of-money-ccf7d5e8c3be
https://medium.com/@collin.cusce/why-business-needs-ethereum-plasma-now-how-it-works-key-components-pt-2-37a82737cd54
https://ethresear.ch/t/plasma-cash-plasma-with-much-less-per-user-data-checking/1298
https://ethresear.ch/t/minimal-viable-plasma/426
https://www.bitrates.com/news/p/plasma-applications-omise-go-loom-network-bankex'
https://ethresear.ch/t/more-viable-plasma/2160

Payment channels in Raiden and LN are set only between two participants, but for an arbitrary number of participants child chains or side chains can be unfolded from the main root chain, anchored in an on-chain contract that defines the rules, conditions and parameters of the side chain instance. The difference between payment channels and side chains is that the latter run a full blockchain protocol instead of a simple payment channel and one usually does not close them but intermittently publishes the current state to the main chain (say, once a day, amounting to the cost of one regular Bitcoin or Ethereum transaction).


In a blockchain, a state can be defined as a list of participants (accounts) and their respective balances at a certain point in time. A state transition is the changing of one state of arrangements to another, updated one.

One idea: Plasma with account/balnaces
// Code in UTXO that gets passed along?


Similar to Lightning Network, blockchains here can be seen a system of courts – child chains as distinct courts of appeal and the public Ethereum root chain functioning as a sort of a supreme court.

Plasma MVP -- easy? (create)

Plasma cash (create)\

Plasma that runs EVM code -- how? UTXO's? Account balances? Special contract transactions?

Another way to implement Plasma, Plasma Cash, is a simplified construction based around the use of unique identifiers for token deposits on the Plasma chain – tokens on the network are assigned unique serial numbers instead of than grouping them in a single reservoir contract. That is, each deposit creates a coin (which cannot be split or merged) with the denomination of what has been deposited in Ether, rather than creating an arbitrary unit of Plasma Ether (PETH). Plasma Cash essentially allows owners to transfer assets to the side chain while keeping the original value secure on the Ethereum mainnet where accountability takes place.

In that scenario, a transaction spending a coin needs to be included in the specific position of the Merkle tree that corresponds to the coin ID. For example, for ID 0 the spend transaction has to be included in the leftmost position all the way left in the Merkle tree. Converting the ID to binary notation (ones and zeros) translates to the description of the Merkle path to the valid transaction. Clients need to verify the availability and correctness of transactions only at the specific indices of any coins that they own or care about, going back to when and where the coin was deposited. This change to how transaction history is stored significantly reduces the amount of data users need to process.

Sharded client-side validation: Users only need to watch the Plasma chain for their tokens (ensuring they have not been double-spent or stolen) allowing transaction throughput to scale without increased load on individual users.

No confirmations: Transactions no longer require pending confirmations but instead, once a transaction is included on the main chain it is already spendable.

Simple support for all tokens: No additional complexity to adding any number distinct tokens, including non-fungible ERC-721 assets (e.g., CryptoKitties).

Mitigating the mass exit vulnerability: Since a thief attempting an exit must submit an exit transaction for each token, mass exits become less of an issue (but there is still an interruption in service since the chain halts).