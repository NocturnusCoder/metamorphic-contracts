// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;


contract MetaDeployer {
    event MutDeployerDeployed(address _addr);

    function createMutDeployer() public returns (MutDeployer mutdeployer){
        mutdeployer = (new MutDeployer){salt: "123456"}();
        emit MutDeployerDeployed(address(mutdeployer));
    }
}

contract MutDeployer {
    event MutDeployed(address _addr);
    
    function deploy_v1() public returns (MutableV1 mutablev1) {
        mutablev1 = new MutableV1();
        emit MutDeployed(address(mutablev1));
    }

    function deploy_v2() public returns (MutableV2 mutablev2){
        mutablev2 = new MutableV2();
        emit MutDeployed(address(mutablev2));

    }

    function destroy() public {
        selfdestruct(payable(msg.sender));
    }
}

contract MutableV1 {
    uint256 public balance = 1000000;
    function destroy() public {
        selfdestruct(payable(msg.sender));
    }
}

contract MutableV2 {
    uint256 public balance = 999999;
    function destroy() public {
        selfdestruct(payable(msg.sender));
    }
}
