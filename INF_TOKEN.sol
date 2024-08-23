// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract INFToken {
    string public name = "INFinitar coin";
    string public symbol = "INF";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address public admin;
    bool public contractActive = true;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event ContractDeactivated();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    modifier isActive() {
        require(contractActive, "Contract is deactivated");
        _;
    }

    constructor() {
        admin = msg.sender;
        totalSupply = 1000000000 * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
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

    function transfer(address _to, uint256 _value) public isActive returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public isActive returns (bool success) {
        require(_spender != address(0), "Invalid address");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public isActive returns (bool success) {
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

    function mint(address _to, uint256 _value) public onlyAdmin isActive returns (bool success) {
        totalSupply = safeAdd(totalSupply, _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public onlyAdmin isActive returns (bool success) {
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

    function deactivateContract() public onlyAdmin {
        contractActive = false;
        emit ContractDeactivated();
    }

    function withdrawEther() public onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }
}