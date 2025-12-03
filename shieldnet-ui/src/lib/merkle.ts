import { poseidonHash } from './crypto'

const MERKLE_DEPTH = 20

function getZeroValues(): bigint[] {
  const zeros: bigint[] = [0n]
  for (let i = 1; i <= MERKLE_DEPTH; i++) {
    zeros[i] = poseidonHash([zeros[i - 1], zeros[i - 1]])
  }
  return zeros
}

const ZERO_VALUES = getZeroValues()

export class MerkleTree {
  private depth: number
  private leaves: bigint[]
  private layers: bigint[][]
  
  constructor(depth: number = MERKLE_DEPTH) {
    this.depth = depth
    this.leaves = []
    this.layers = []
    this.rebuild()
  }
  
  private rebuild(): void {
    this.layers = [this.leaves.slice()]
    
    for (let level = 0; level < this.depth; level++) {
      const currentLayer = this.layers[level]
      const nextLayer: bigint[] = []
      const levelSize = Math.pow(2, this.depth - level)
      
      for (let i = 0; i < levelSize; i += 2) {
        const left = currentLayer[i] ?? ZERO_VALUES[level]
        const right = currentLayer[i + 1] ?? ZERO_VALUES[level]
        nextLayer.push(poseidonHash([left, right]))
      }
      
      this.layers.push(nextLayer)
    }
  }
  
  insert(leaf: bigint): number {
    const index = this.leaves.length
    this.leaves.push(leaf)
    this.rebuild()
    return index
  }
  
  getRoot(): bigint {
    if (this.layers.length === 0) return ZERO_VALUES[this.depth]
    return this.layers[this.layers.length - 1][0] ?? ZERO_VALUES[this.depth]
  }
  
  getProof(index: number): bigint[] {
    const proof: bigint[] = []
    let currentIndex = index
    
    for (let level = 0; level < this.depth; level++) {
      const siblingIndex = currentIndex % 2 === 0 ? currentIndex + 1 : currentIndex - 1
      const sibling = this.layers[level]?.[siblingIndex] ?? ZERO_VALUES[level]
      proof.push(sibling)
      currentIndex = Math.floor(currentIndex / 2)
    }
    
    return proof
  }
  
  getLeafCount(): number {
    return this.leaves.length
  }
}