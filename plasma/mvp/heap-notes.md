
# On the route to Plasma-MVP

*In this series, I will be describing what **Plasma** is, how it works and how to create your own plasma chain*

## Plasma

Plasma is a layer 2 scaling solution created by Joseph Poon and Vitalik Buterin [here](https://plasma.io/).

### What do we mean by layer 2 scaling solution?

Public blockchains are great for trustless computations, transferring value, creating digital scarcity and many other applications etc. 

This is an amazing property of blockchains, but it comes at the cost of scalability. To achieve this, all nodes on the network need to validate and store all transactions since the beginning of the blockchain history, the genesis block. As the blockchain history grows, so is its storage needs. One can wonder why you would need to save all information on the blockchain if you only use 1 application?

Also, most blockchains has an upper limit to the block size. This means that there is an upper limit as to how many transactions can be added to the block and so to the blockchain. Ethereum has maximally about 15 tps whereas bitcoin is about 7 tps. With credit card companies needing upwards of 5000 tps, we can see that Ethereum would not be able to scale.

Here layer 2 scaling solutions refer to mainly off-chain solutions like State Channels (I wrote a bit about payment channels [here](https://medium.com/@patrick.guay43/demistifying-payment-channels-c2e3604fd798)) and [Truebit](https://truebit.io/). An example of a layer 1 scaling solution would be [sharding](https://medium.com/prysmatic-labs/how-to-scale-ethereum-sharding-explained-ba2e283b7fce)

### Brief Plasma introduction

Plasma is essentially a way to be able to create a **sidechain** with its own rules and consensus algorithm while still having the security benefits of the main chain.

As Buterin and Poon explain in their paper:

> We call this framework a Plasma blockchain. For funds held in the Plasma chain,
this allows for deposit and withdrawal of funds into the Plasma chain, with state transitions
enforced by fraud proofs. This allows for enforcible state and fungibility since one is able
to deposit and withdraw, with accounting of the Plasma block matching the funds held in
the root chain.

This is extremely powerful as a user of such a plasma chain can be sure that they would get their money (coin, token, Cryptokitty) back in the case the plasma chain operator behaves badly. Also Poon and Buterin explain that the data stored in this side chain does not need to be fully included in the root chain (Ethereum), only a representation of it that allows for fraud proofs:


> The Plasma blockchain does not disclose the contents of the blockchain on the root chain (e.g.
Ethereum). Instead, blockheader hashes are submitted on the root chain and if there is proof of fraud
submitted on the root chain, then the block is rolled back and the block creator is penalized. This is very
efficient, as many state updates are represented by a single hash.

As we go further in this series, we wil get to understand how these fraud proofs work, and how to create our own.

## Plasma MVP

On January 3rd 2018, Buterin released the minimal specifications for a *minimal viable plasma implementation*. This MVP is simply called [Plasma-MVP](https://ethresear.ch/t/minimal-viable-plasma/426).


Thankfully this MVP is very simple, here is a borad list of what we need to implement:

- A root chain contract with certain features:
    - A priority queue data structure
    - At least 4 functions (`submitBlock`, `deposit`, `startExit`, `challengeExit`) and a plasma block list
    - A plasma chain implementation with a specific RLP encoded structure for transactions and specific state transitions.

In this tutorial, we will start with the the implementation of a `heap` data structure in solidity, this heap will work as our priority queue for the plasma MVP.

## Heaps

A heap is a tree-based data structure. In this data structure, we call all entities "nodes" and nodes can have one parent node and/or multiple children nodes. The top node that has no parent is called the root node. This specific data structure has a specific set of properties that we call heap properties:

- Depending on the type of heap, the parent is either greater than or equal to (or the opposite) to its children.
- Children are always added "left-first", meaning when drawing such a tree, if we happend to be at a node that has no children, it's first child will be a left node 

In this tutorial, we will be creating a *Priority Queue*, which means that we will be creating a *max-heap*. In mathematical terms, if P is the parent node and C1 and C2 are the children, we need to ensure that `P >= C1 && P >= C2` holds for all nodes in the tree.

This property gives us the simple fact that the top of the tree (or the root node) will the maximum number in the set. This then means that if we have a mechanism to remove the root node and rebalance the tree, we've created a priority queue!

## Implementation

To store all the nodes in the heap, we will be using an array that we will simply call `heap`. To make life easier for us, we will be starting our heap at index 1, so we will first initialize our array with a `0` first index of the array.


```javascript
    constructor() public {
        // Start at 0
        heap = [0];
    }

```

### Storing the heap

How will we be storing such a heap in the array?

Let's think about this a little bit. We are starting at index 1, which is our root node. As we insert more nodes, we push them into our array. As we always add child nodes "left-first", let's decide that the next element in our array is the left child, followed by the right child. This means that at index 1 we have the parent, at index 2 the left child and index 3 the right child. Going down another level, we the parent node is now at index 2. The left child now will be added at index 4, and the right child at index 5.

Generalizing this construction, we see that we have a node at position `k`, the children are at node `2*k` and `(2*k)+1`. Conversely, for a node at position `k` that is not the root node, the parent is at `k/2`.

### Insert Operation

We now know how to efficiently store our heap, let's focus on inserting a node into it. Thankfully the insert logic is pretty straightforward. Essentially what we want to do is ensure that our tree is alway valid (meaning the parent node needs to always be of higher value). To do a proper insert, we push the value to the end of the heap (here the last element in our array). From there we compare our node with its parent and if the node is of higher value, then we swap the parent and the node and keep going until either we reached the root node or the node is not higher than its parent. This is commonly called "bubbling up" as the node bubbles up the tree.

```javascript
    // Inserts adds in a value to our heap.
    function insert(uint256 _value) public {
        // Add the value to the end of our array
        heap.push(_value);
        // Start at the end of the array
        uint256 currentIndex = heap.length.sub(1);
        // Bubble up the value until it reaches it's correct place (i.e. it is smaller than it's parent)
        while(currentIndex > 1 && heap[currentIndex.div(2)] < heap[currentIndex]) {
        // If the parent value is lower than our current value, we swap them
        (heap[currentIndex.div(2)], heap[currentIndex]) = (_value, heap[currentIndex.div(2)]);
        // change our current Index to go up to the parent
        currentIndex = currentIndex.div(2);
        }
    }
```


### RemoveMax

The main purpose of a heap is to be able to remove either a maximum or minimum efficiently. As we can see, reading the maximum number in our set is trivial, it is simply a read of the root node which takes O(1) operation. Removing the root node is more complicated, as we would break the tree properties that we need to abide by.

What we need to do in this case is to remove the top node and replace it with the last element of the tree. We take the root node and compare it to its children, if the node is not greater than it's children, then we swap it with the **greater** child. We do these operations until either the parent node is greater than both its children or we've reached the end of the tree, which at this point our node becomes a leaf. This is called "bubbling down" the heap.

```javascript
function removeMax() public returns(uint256){
        // Ensure the heap exists
        require(heap.length > 1);
        // take the root value of the heap
        uint256 toReturn = heap[1];

        // Takes the last element of the array and puts it at the root
        heap[1] = heap[heap.length.sub(1)];
        // Delete the last element from the array
        heap.length = heap.length.sub(1);

        // Start at the top
        uint256 currentIndex = 1;

        // Bubble down
        while(currentIndex.mul(2) < heap.length.sub(1)) {
            // get the current index of the children
            uint256 j = currentIndex.mul(2);

            // left child value
            uint256 leftChild = heap[j];
            // right child value
            uint256 rightChild = heap[j.add(1)];

            // Compare the left and right child. if the rightChild is greater, then point j to it's index
            if (leftChild < rightChild) {
                j = j.add(1);
            }

            // compare the current parent value with the highest child, if the parent is greater, we're done
            if(heap[currentIndex] > heap[j]) {
                break;
            }

            // else swap the value
            (heap[currentIndex], heap[j]) = (heap[j], heap[currentIndex]);

            // and let's keep going down the heap
            currentIndex = j;
        }
            // finally, return the top of the heap
            return toReturn;
    }
```

## Gas cost and efficiency

How can we know that the heap makes sense for your case here? I seriously hope that all exprienced Solidity developers gasped when they saw this code, as we're using `while` loops. `for` and `while` loops are very often dangerous in solidity because of the **block gas limit**. Essentially if we have an unbounded or dynamically bounded for loop, it's possible that the operations done in this loop use so much gas that they require more gas than the block gas limit. When this happens, no one will be able to run such a function and the contract is what is colloquially called `bricked`.

Let's see how many operations it would take to reach the current block gas limit. As of the time of writing the block gas limit is approximately 8000000 gas units.

### Heap properties

A heap is a very useful structure. Thanks to how it is built, we can derive a relationship between two of the most important properties of a tree, it's height and the number of nodes. For a heap of N nodes, its height is `log_2(N)`. Conversely, to calculate the approximate amount of nodes in a tree of height `h`, we do `2^h`. Actually the max number of nodes in a tree of height h is `2^(h+1) -1` and minimum is `2^h` so we have a nice upper and lower bound for our total amount of nodes N: `2^h <= N <= 2^(h+1) - 1`.

When doing an `insert`, at every step of the while loop, we need to compare the value with its parents. That means we need to do at most `log2(N) - 1` comparisons for it to bubble all the way to the top.

Now for a `removeMax`, we need to compare both children and the parent, which means we have at most `2*(log2(N) - 1)` comparisons to do.

So here we expect insert to be slightly less expensive (in terms of gas expenditure) than removeMax.

### Insert

We've created a small simulation where we call the `insert` function 100 times in our heap with the worst case scenario (where the node has to bubble all the way up to the root node) and we call `removeMax` 100 times too but in the worst case scenario (where the node needs to bubble down all the way to the end of the heap). 

We've plotted the gas consumption for both `insert` and `removeMax`.

// ADD INSERT GRAPH

What is interesting to see here for the inserts, is that every new height of the tree, we are adding a constant amount of gas, here `12694`. This is the cost of one full iteration going up the tree (swap, getting the node from memory and comparisons). Now as the height of the tree grows logarithmically, let's see how many nodes we need to have in the tree before we reach the block gas limit.

The cost of adding only 1 element to an empty tree is `47434`, this will be our "baseline" constant. Let's see how many elements we need to have before we reach the limit. Let `h` be the height of the tree. For every step we require `12694` gas, so we can calculate how big the height of the tree needs to be:

```bash
47434 + h*12694 = 8000000

h = (8000000 - 47434) / 12694

h ~= 626.48

```

With a height of 626, we would need `2^626` entries in the heap before we reach the block gas limit. It's safe to say we will not reach this limit.

It is very much the same with remove max, albeit it does need more comparisons than insert. Assuming a worse case scenario, we would double the amount of comparisons which means a higher amount of gas per step in the loop. In our simulation, we take the average difference, about 18000. SO this gives us:


```bash
47434 + h*18000 = 8000000

h = (8000000 - 47434) / 18000

h ~= 441.81

```

Again, `2^441` is an extremely large number, it would not be feasible for our smart contract to get bricked.

## Conclusion

We've now successfully created our heap data structure that we will be using as our priority queue for our **Plasma MVP** implementation. We've showed that this data structure let's us do inserts and remove the maximum of the set in a very efficient way and we've showed that we don't need to be worried about our `while` loop in our solidity code, this calculation will never reach the block gas limit and brick our contract. Now we can continue on our quest for the plasma MVP!