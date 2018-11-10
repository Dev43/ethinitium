const Heap = artifacts.require("./Heap.sol")
contract('Heap', function(accounts) {

  it("should create a valid heap by calling insert", async() => {
      let heap = await Heap.new();
      testData = [6, 5, 4, 2, 1, 3, 34];
      for(let i = 0; i < testData.length; i++) {
        await heap.insert(testData[i]);
      }
    
      finalHeap = (await heap.getHeap())
      answer = [0, 34, 5, 6, 2, 1, 3, 4];
      assertEqual(answer, finalHeap)
    })

    it("should removeMax from a valid heap ", async() => {
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

    it("Adds 100 elements in the heap ", async() => {
      let heap = await Heap.new();
      for(let i = 0; i < 100; i++) {
        num = Math.floor(Math.random()*1000000)
        await heap.insert(num);
      }
      
      max = await heap.removeMax()
      console.log(max.receipt.gasUsed)
      ins = await heap.insert(100000000)
      console.log(ins.receipt.gasUsed)
      max = await heap.removeMax()
      console.log(max.receipt.gasUsed)
      ins = await heap.insert(1)
      console.log(ins.receipt.gasUsed)
      
    })
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