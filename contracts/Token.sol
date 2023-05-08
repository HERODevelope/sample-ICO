pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is IERC20 {
    address public owner;
    uint256 private _totalSupply = 0;
    uint256 private _initialSupply = 5000;
    mapping(address => uint256) private _balances;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    constructor() {
        owner = msg.sender;
        _balances[owner] = _initialSupply; // Pre-mint 5000 tokens to owner's address
        _totalSupply = _initialSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function mint(address _to, uint _amount) public onlyOwner {
        require(_to != address(0), "Invalid address.");
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: insufficient balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}
