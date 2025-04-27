# Metamorphic Contracts and Deployment Scripts
These contracts are for test purposes and should not be used in production environments.

## Relevant Information
- [Metamorphic Smart Contracts: Is EVM Code Truly Immutable? (MixBytes Blog)](https://mixbytes.io/blog/metamorphic-smart-contracts-is-evm-code-truly-immutable)
- [0xOwenThurm Twitter Thread](https://x.com/0xOwenThurm/status/1663296914853621760)

## Prerequisites

- `foundry.toml` does not affect contracts deployed to Anvil.
- **EVM Version:** Shanghai should be selected. Otherwise, `selfdestruct` only sends ether and contracts are not destroyed. This must be specified in Anvil:  
  `anvil --hardfork shanghai`
- A new contract (`MetaDeployer`) is deployed with `CREATE`. This contract has a `CREATE2` function to create a factory contract (`MutDeployer`).
- The `MutDeployer` contract has 3 functions:
  1. Deploys a V1 version of an implementation contract.
  2. Deploys a V2 version of an implementation contract.
  3. Destroys (selfdestructs) itself.
- The two implementation contracts each have arbitrary functions and variables, but both must have a `destroy` (`selfdestruct`) function.

## How to Deploy the Metamorphic Contracts

1. **The `MetaDeployer` contract is deployed at address A.**  
   It has a function to deploy `MutDeployer` using `CREATE2`.
2. **`MetaDeployer` deploys the `MutDeployer` contract using `CREATE2` at address B.**  
   `CREATE2` is used so that the same contract can be redeployed to the same address after `MutDeployer` is destroyed. This is necessary because `MutDeployer` will deploy V2 of the implementation contract, and to deploy V2 to the same address as V1, the nonce of `MutDeployer` must be reset. Once reset, `MutDeployer` can deploy V2 to the same address as the destroyed V1 implementation contract.
3. **`MutDeployer` deploys the V1 implementation contract at address C.**
4. **V1 implementation contract is destroyed.**  
   There is no contract at address C at this point.
5. **`MutDeployer` is destroyed.**  
   There is no contract at address B at this point.
6. **`MetaDeployer` deploys the same `MutDeployer` contract using `CREATE2` at address B again.**  
   The nonce is now reset.
7. **V2 implementation contract is deployed at the same address where V1 was deployed (address C).**
8. This process ensures that the V2 implementation contract is deployed at the same address as the V1 implementation contract, maintaining consistency in contract addresses.

## Running the Scripts

The reason for having a two-part script is to complete the destroy process. `selfdestruct` is completed at the end of a block.

The addresses deployed in the first part of the script are saved to a directory called `vmreadwritefile`.

Scripts need to be run separately:

`anvil --hardfork shanghai`

```sh
forge script MetaDeployerScript --broadcast --rpc-url localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --sig "run1()" -vvvvv
forge script MetaDeployerScript --broadcast --rpc-url localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --sig "run2()" -vvvvv
```
## Running the tests
Test file is not complete nad outputs collision error. I couldn't find a way to complete the selfdestruct transaction yet.



