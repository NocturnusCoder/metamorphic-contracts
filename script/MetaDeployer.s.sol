// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Script, console} from "forge-std/Script.sol";
import "../src/MetaDeployer.sol";

contract MetaDeployerScript is Script {
    MetaDeployer metadeployer;
    MutDeployer mutdeployer;
    MutableV1 mutablev1;
    MutableV2 mutablev2;
    
    function run1() public {
        vm.startBroadcast();

        // MetaDeployer is deployed with create. Address is saved to a file.
        metadeployer = new MetaDeployer();
        vm.writeFile("./script/vmreadwritefile/metadeployer.addr", vm.toString(address(metadeployer)));

        // MutDeployer is deployed with Create2. Address is saved to a file.
        mutdeployer = metadeployer.createMutDeployer();
        vm.writeFile("./script/vmreadwritefile/mutdeployer.addr", vm.toString(address(mutdeployer)));
        
        // mutabeV1 is deployed with Create. Address is saved to a file.
        mutablev1 = mutdeployer.deploy_v1();
        vm.writeFile("./script/vmreadwritefile/mutablev1.addr", vm.toString(address(mutablev1)));
        require(vm.getNonce(address(mutdeployer)) == 2, "Nonce is not zero");

        mutablev1.destroy();
        
        mutdeployer.destroy();

        vm.stopBroadcast();
    }

    function run2() public {
        vm.startBroadcast();

        string memory addrStr = vm.readFile("./script/vmreadwritefile/mutdeployer.addr");
        address mutdeployerAddr = vm.parseAddress(addrStr);
        require(getCodeSize(mutdeployerAddr) == 0, "MutDeployer was not destroyed");

        addrStr = vm.readFile("./script/vmreadwritefile/mutablev1.addr");
        address mutablev1Addr = vm.parseAddress(addrStr);
        require(getCodeSize(mutablev1Addr) == 0, "MutableV1 was not destroyed");

        addrStr = vm.readFile("./script/vmreadwritefile/metadeployer.addr");
        address metadeployerAddr = vm.parseAddress(addrStr);
        MutDeployer mutdeployer2 = MetaDeployer(metadeployerAddr).createMutDeployer();
        require(address(mutdeployer2) == mutdeployerAddr, "MutDeployer address mismatch");
        require(vm.getNonce(address(mutdeployer2)) == 1, "Nonce is not 1");
        
        mutablev2 = mutdeployer2.deploy_v2();

        vm.stopBroadcast();
    }

    function getCodeSize(address _contract) public view returns (uint256 size) {
        assembly {
            size := extcodesize(_contract)
        }
    }
    
}
