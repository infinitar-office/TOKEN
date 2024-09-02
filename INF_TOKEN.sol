// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract INFToken {
    string public constant name = "INFinitar coin";
    string public constant symbol = "INF";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address public admin;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    constructor(address _multisigAdmin) {
        require(_multisigAdmin != address(0), "Invalid multisig admin address");
        admin = _multisigAdmin;
        totalSupply = 0;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyAdmin returns (bool success) {
        require(_to != address(0), "Cannot mint to the zero address");
        require(_value > 0, "Mint value must be greater than zero");
        totalSupply = safeAdd(totalSupply, _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public onlyAdmin returns (bool success) {
        require(_from != address(0), "Cannot burn from the zero address");
        require(_value > 0, "Burn value must be greater than zero");
        require(balanceOf[_from] >= _value, "Insufficient balance to burn");
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        totalSupply = safeSub(totalSupply, _value);
        emit Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }


}
