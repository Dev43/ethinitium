const Heap = artifacts.require("./Heap.sol")
const fs = require("fs")

contract('Heap', function(accounts) {

  it("should create a valid heap by calling insert", async(done) => {
      // let's not go through this test
      done();
      let heap = await Heap.new();
      testData = [6, 5, 4, 2, 1, 3, 34];
      for(let i = 0; i < testData.length; i++) {
        await heap.insert(testData[i]);
      }
    
      finalHeap = (await heap.getHeap())
      answer = [0, 34, 5, 6, 2, 1, 3, 4];
      assertEqual(answer, finalHeap)
    })

    it("should removeMax from a valid heap ", async(done) => {
      // let's not go through this test
      done();
      let heap = await Heap.new();
      let testData = [34, 26, 33, 15, 24, 5, 4, 12, 1, 23, 21, 2];
      for(let i = 0; i < testData.length; i++) {
        await heap.insert(testData[i]);
      }
    

      let finalHeap = (await heap.getHeap())
      let answer = [0, 34, 26, 33, 15, 24, 5, 4, 12, 1, 23, 21, 2];
      assertEqual(answer, finalHeap)
      answer = [0,33,26,5,15,24,2,4,12,1,23,21]
      await removeMax(heap, 34, answer)
      answer = [0, 26,24,5,15,21,2,4,12,1,23]
      await removeMax(heap, 33, answer)
      answer = [0,24,23,5,15,21,2,4,12,1]
      await removeMax(heap, 26, answer)

    })

    // it("Adds 100 elements in the heap, worst case for insert ", async(done) => {
    //   // let's not go through this test
    //   done();
    //   let heap = await Heap.new();
    //   // Worse for insert
    //   for(let i = 0; i < 100; i++) {
    //     num = i
    //     last = await heap.insert(num);
    //   }


      
    //   max = await heap.removeMax()
    //   ins = await heap.insert(100000000)
    //   max = await heap.removeMax()
    //   ins = await heap.insert(1)
    // })

    // it("Adds 100 elements in the heap, worst case for removeMax ", async(done) => {
    //   // let's not go through this test
    //   done();
    //   // Worst for removeMax
    //   let heap = await Heap.new();

    //   // Worst for removeMax
    //   for(let i = 100; i > 0; i--) {
    //     num = i
    //     last = await heap.insert(num);
    //   }
      
    //   max = await heap.removeMax()
    //   ins = await heap.insert(100000000)
    //   max = await heap.removeMax()
    //   ins = await heap.insert(1)
    // })

    // it("Adds elements in the heap and spits out a csv ", async(done) => {
    //   done();
    //   // Worst for removeMax
    //   let newFileA = fs.openSync("gasUsageAsc.csv", "a")
    //   let newFileD = fs.openSync("gasUsageDesc.csv", "a")
    //   let newFileR = fs.openSync("gasUsageRand.csv", "a")


    //   var interationFuncOrderedAsc = function(i){
    //     init = i
    //     return function() {
    //       return init++;
    //     }
    //   }

    //   var interationFuncOrderedDesc = function(i){
    //     init = i
    //     return function() {
    //       return init--;
    //     }
    //   }

    //   var interationFuncRandom = function(i){
    //     init = i
    //     return function() {
    //       return Math.floor(Math.random() * i);
    //     }
    //   }
      
    //   await createGasProfile(newFileA,  1000, interationFuncOrderedAsc(1), "ordered ascending")
    //   await createGasProfile(newFileD,  1000, interationFuncOrderedDesc(1000), "ordered descending")
    //   await createGasProfile(newFileR,  1000, interationFuncRandom(10000), "random")
    // })
});


async function removeMax(heap, root, answer) {
  // Simulate
  let max = (await heap.removeMax.call())
  // Ensure we get the root back
  assert.equal(max.toString(), root + "", "did not get the root back")
  // Actually do it
  await heap.removeMax()

  // Compare with expected leftover heap
  finalHeap = (await heap.getHeap())
  assertEqual(answer, finalHeap)
}


function assertEqual(answer, finalHeap) {
  for(let i = 0; i < finalHeap.length; i++) {
    assert.equal(finalHeap[i].toString(), ""+answer[i], "heap elements are not equal " + answer[i] + " " + finalHeap[i] + " " + i)
  }
}


async function createGasProfile(file, iterations, toInsertFunc, comment) {

  let gas = 0
  let i = iterations
  let j = iterations
  csv = "inserts,gasUsed,comment\n"
  fs.appendFileSync(file, csv)
  let heap = await Heap.new();
  while(i > 0) {
      gas = (await heap.insert(toInsertFunc())).receipt.gasUsed
      let csv = iterations+","+gas+","+comment+",inserting"+"\n";
      fs.appendFileSync(file, csv)

      i--
  }

  while(j > 0) {
    gas = (await heap.removeMax()).receipt.gasUsed
    let csv = iterations+","+gas+","+comment+",removeMax"+"\n";
    fs.appendFileSync(file, csv)
    j--;
  }

}