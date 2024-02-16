/**
 *Submitted for verification at Etherscan.io on 2023-09-29
*/

pragma solidity ^0.8.10;

contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "Subtraction underflow");
        uint c = a - b;
        return c;
    }

    function safeMul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "Multiplication overflow");
        return c;
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        require(b > 0, "Division by zero");
        uint c = a / b;
        return c;
    }
}


//ERC Token Standard #20 Interface

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view  returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


//Contract function to receive approval and execute function in one call

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}

//Actual token contract

contract HARAMBEToken is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        symbol = "HARAMBEAI";
        name = "Harambe AI Token";
        decimals = 18;
        _totalSupply = 690000000000000000000000000;
        balances[0x06D344b9ada316c83C30110Ca6029d49961eC907] = _totalSupply;
        emit Transfer(address(0), 0x06D344b9ada316c83C30110Ca6029d49961eC907, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes calldata data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    fallback () external {
        revert();
    }
    receive() external payable {
        // React to receiving ether; currently, your fallback just reverts, so:
        revert("ETH not accepted");
    }
}
