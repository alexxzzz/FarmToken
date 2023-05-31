// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/GatitoToken.sol";
import "contracts/ZoeToken.sol";

contract tokenFarm {

    // Declaraciones iniciales
    string public name = "Zoe Token Farm";
    address public owner;
    GatitoToken public gatitoToken;
    ZoeToken public zoeToken;

    // Estructuras de datos
    address [] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping (address => bool) public hasStaked;
    mapping (address => bool) public isStaking;

    // Constructor 
    constructor(ZoeToken _zoeToken, GatitoToken _gatitoToken) {
        zoeToken = _zoeToken;
        gatitoToken = _gatitoToken;
        owner = msg.sender;
    }

    // Stake de tokens
    function stakeTokens (uint _amount) public {
        // Se requiere una cantidad superior a 0
        require(_amount > 0, "La cantidad no puede ser menor a 0" );
        // Transferir tokens JAM al Smart Contract principal
        gatitoToken.transferFrom(msg.sender, address(this), _amount);
        // Actualizar el saldo del staking
        stakingBalance[msg.sender] += _amount;
        // Guardar el usuario
        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
        }

        //Actualizamos el valor del staking
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Quitar el staking de los tokens
    function unstakeTokens() public {
        // Saldo del staking de un usuario
        uint balance = stakingBalance[msg.sender];
        // Se reuquiere cantidad mayor a 0
        require (balance > 0, "El balance del staking es 0");
        // Transferencia de los tokens al usuario
        gatitoToken.transferToken(msg.sender, balance);
        // Resetea el balance de Staking del usuario
        stakingBalance[msg.sender] = 0;
        // Actualizamos el estado del staking
        isStaking[msg.sender] = false;
    }

    // Emision de Tokens de recompensa
    function issueTokens() public {
        // Unicamente ejecutable por el owner
        require(msg.sender == owner, "No eres el owner");
        // Emitir tokens a todos los stakers
        for (uint i=0; i < stakers.length; i++){
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0){
            zoeToken.transferToken(recipient, balance);
            }
        }
    }


}