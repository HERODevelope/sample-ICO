pragma solidity >=0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Token.sol";

contract ICO {
    uint public constant TOKEN_SUPPLY = 1000000 * 10 ** 18; // 1 million tokens
    uint public constant RATE = 1000;
    uint public constant DAYS = 1;
    uint public constant START = 1707312000;
    uint public constant END = START.add(DAYS * 1 days);
    uint public constant SOFTCAP = 0.1;
    uint public constant HARDCAP = 1;
    uint public constant MINPURCHASE = 0.01;
    uint public constant MAXPURCHASE = 0.05;
    uint public raisedAmount = 0;
    // bool public isClosed;

    mapping(address => uint) public balances;

    event Deposit(address indexed investor, uint amount);
    event Withdraw(address indexed investor, uint amount);
    event Claim(address indexed investor, uint amount);

    modifier isPossible() {
        require(now >= START, "ICO has not yet started.");
        require(now <= END, "ICO has ended.");
        // require(!isClosed, "ICO is closed.");
        _;
    }

    constructor(address _tokenAddr) public {
        require(_tokenAddr != 0, "Must have account");
        token = Token(_tokenAddr);
    }

    function deposit(uint tokens) public payable isPossible {
        require(msg.value >= MINPURCHASE, "Deposit amount is below minimum.");
        require(msg.value <= MAXPURCHASE, "Deposit amount is above maximum.");
        // require(
        //     msg.value.add(balances[msg.sender]) <= hardCap,
        //     "Deposit amount exceeds hard cap."
        // );
        uint BNBAmount = tokens.div(RATE);
        
        raisedAmount = raisedAmount.add(BNBAmount);
        token.transfer(msg.sender, tokens);

        balances[msg.sender] += tokens;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(
            (now > END && balances[msg.sender] > 0),
            "Withdrawals not allowed at this time."
        );
        uint tokens = balances[msg.sender];
        uint BNBAmount = tokens.div(RATE);

        raisedAmount = raisedAmount.sub(BNBAmount);
        token.transferFrom(msg.sender, address(this), tokens);

        balances[msg.sender] = 0;
        // payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function claim(unit tokens) public {
        require(
            (( now > END && balances[msg.sender] > tokens && raisedAmount >= SOFTCAP )||( raisedAmount >= HARDCAP )),
            "Withdrawals not allowed at this time."
        );

        uint BNBAmount = tokens.div(RATE);
        
        raisedAmount = raisedAmount.sub(BNBAmount);
        token.transferFrom(msg.sender, address(this), tokens);

        balances[msg.sender] -= tokens;
        emit Claim(msg.sender, amount);
    }
}
