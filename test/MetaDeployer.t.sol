// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console} from "forge-std/Test.sol";
import  "../src/MetaDeployer.sol";

contract MetDeployerTest is Test {
    MetaDeployer metadeployer;

    function setUp() public {
        metadeployer = new MetaDeployer();
        //vm.createSelectFork("https://mainnet.gateway.tenderly.co/1syHFEkXU3h6WR6W2aIrnR", 17_000_000);
    }

    function test() public {
        MutDeployer mutdeployer = metadeployer.createMutDeployer();
        MutableV1 mutablev1 = mutdeployer.deploy_v1();
        
        mutablev1.destroy();

        vm.roll(block.number + 1);
        
        console.log("mutablev1 codesize:", getCodeSize(address(mutablev1)));
        
        mutdeployer.destroy();

        //MutDeployer mutdeployer2 = metdeployer.createMutDeployer();
        MutableV2 mutablev2 = mutdeployer.deploy_v2();

        assertEq(address(mutablev1), address(mutablev2));

        console.log("balance", address(mutdeployer).balance);
        console.log("mutdeployer address:", address(mutdeployer));
        //console.log("mutdeployer2 address:", address(mutdeployer2));
        console.log("mutablev1 address:", address(mutablev1));
        console.log("mutablev2 address:", address(mutablev2));
    }

    function getCodeSize(address _contract) public view returns (uint256 size) {
        assembly {
            size := extcodesize(_contract)
        }
    }
}
