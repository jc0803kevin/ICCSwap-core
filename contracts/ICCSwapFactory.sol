pragma solidity =0.5.16;

import './interfaces/IICCSwapFactory.sol';
import './ICCSwapPair.sol';

contract ICCSwapFactory is IICCSwapFactory {
    //接收资金的地址
    address public feeTo;
    //有权更改 feeTo 地址的账户
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'ICCSwap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ICCSwap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'ICCSwap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(ICCSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IICCSwapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        // 只有 feeToSetter 账户 可以更改 FeeTo 地址
        require(msg.sender == feeToSetter, 'ICCSwap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        // feeToSetter 地址可以更换
        require(msg.sender == feeToSetter, 'ICCSwap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
