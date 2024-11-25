// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15; // Especifica la versión del compilador de Solidity

// Safe Math Library
library SafeMath {
    // Suma segura que previene desbordamientos
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "SafeMath: addition overflow"); // Verifica que no haya desbordamiento
    }

    // Resta segura que previene subdesbordamientos
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMath: subtraction overflow"); // Verifica que no haya subdesbordamiento
        c = a - b;
    }

    // Multiplicación segura que previene desbordamientos
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "SafeMath: multiplication overflow"); // Verifica que no haya desbordamiento
    }

    // División segura que previene división por cero
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "SafeMath: division by zero"); // Verifica que el divisor no sea cero
        c = a / b;
    }
}

// ERC20 Interface
interface ERC20Interface {
    // Retorna el suministro total de tokens
    function totalSupply() external view returns (uint);
    
    // Retorna el saldo de un propietario de tokens
    function balanceOf(address tokenOwner) external view returns (uint balance);
    
    // Retorna la cantidad de tokens que un gastador puede gastar en nombre de un propietario
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    
    // Transfiere tokens a una dirección
    function transfer(address to, uint tokens) external returns (bool success);
    
    // Aprueba a un gastador a gastar una cantidad específica de tokens
    function approve(address spender, uint tokens) external returns (bool success);
    
    // Transfiere tokens desde una dirección a otra en nombre de un propietario
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    // Evento que se emite cuando se realiza una transferencia de tokens
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    // Evento que se emite cuando se aprueba a un gastador
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Contrato del Token
contract TokenContract is ERC20Interface {
    using SafeMath for uint; // Utiliza la biblioteca SafeMath para operaciones aritméticas seguras

    string public symbol; // Símbolo del token (ej. "PAW")
    string public name;   // Nombre del token (ej. "PetPaws")
    uint8 public decimals; // Número de decimales que el token utilizará
    uint private _totalSupply; // Suministro total de tokens

    // Mapeo para almacenar los saldos de los propietarios de tokens
    mapping(address => uint) balances;
    // Mapeo para almacenar las cantidades permitidas que un gastador puede gastar en nombre de un propietario
    mapping(address => mapping(address => uint)) allowed;

    // Constructor del contrato
    constructor() {
        symbol = "PAW"; // Inicializa el símbolo del token
        name = "PetPaws"; // Inicializa el nombre del token
        decimals = 0; // Inicializa el número de decimales
        _totalSupply = 100000 * 10 ** uint(0); // Inicializa el suministro total de tokens
        balances[msg.sender] = _totalSupply; // Asigna el suministro total al creador del contrato
        emit Transfer(address(0), msg.sender, _totalSupply); // Emite un evento de transferencia para el suministro inicial
    }

    // Retorna el suministro total de tokens, excluyendo los tokens en la dirección cero
    function totalSupply() public view override returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    // Retorna el saldo de un propietario de tokens
    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    // Transfiere tokens a una dirección
    function transfer(address to, uint tokens) public override returns (bool success) {
        balances[msg.sender] = balances[msg.sender].safeSub(tokens); // Resta los tokens del remitente
        balances[to] = balances[to].safeAdd(tokens); // Añade los tokens al destinatario
        emit Transfer(msg.sender, to, tokens); // Emite un evento de transferencia
        return true;
    }

    // Aprueba a un gastador a gastar una cantidad específica de tokens
    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens; // Establece la cantidad permitida
        emit Approval(msg.sender, spender, tokens); // Emite un evento de aprobación
        return true;
    }

    // Transfiere tokens desde una dirección a otra en nombre de un propietario
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        balances[from] = balances[from].safeSub(tokens); // Resta los tokens de la dirección del propietario
        allowed[from][msg.sender] = allowed[from][msg.sender].safeSub(tokens); // Resta la cantidad permitida
        balances[to] = balances[to].safeAdd(tokens); // Añade los tokens al destinatario
        emit Transfer(from, to, tokens); // Emite un evento de transferencia
        return true;
    }

    // Retorna la cantidad de tokens que un gastador puede gastar en nombre de un propietario
    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return allowed[tokenOwner][spender]; // Devuelve la cantidad permitida
    }
}

