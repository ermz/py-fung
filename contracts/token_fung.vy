# @version ^0.2.0

# we need to keep track of _balances per address
# retrieve the balance of any address
# transfer from one address to another
# give our token a name
# we need to be able to deal with decimals
# we need to be able to allow other smart contracts to interact with our token
# produce relevant events

event Transfer_completed:
    sender: indexed(address)
    receiver: address
    amount: uint256
    
event Token_minted:
    receiver: indexed(address)
    amount: uint256
    total_supply_minted: uint256

token_library: HashMap[address, uint256]
token_approval: HashMap[address, HashMap[address, uint256]]

TOKEN_AMOUNT: constant(uint256) = 1000000
NAME: constant(String[10]) = "EdsonToken"

owner: address
moving_token: uint256

@external
def __init__(addr: address):
    self.owner = addr

@external
@view
def name() -> String[10]:
    return NAME

@external
@view
def total_supply() -> uint256:
    return TOKEN_AMOUNT

@external
@view
def balance_of(addr: address) -> uint256:
    return self.token_library[addr]

@external
@view
def allowance(addr: address, spender: address) -> uint256:
    return self.token_approval[addr][spender]

@external
def approve_address(addr: address, amount: uint256) -> bool:
    # assert that there are enough funds to be given approval over, otherwise it doeesn't make sense
    assert self.token_library[msg.sender] >= amount
    # Based on token address holder, give other accounts(addresses) approval to move funds and the amount allowed
    self.token_approval[msg.sender][addr] = amount
    return True

@external
def transfer_from(sender: address, receiver: address, amount: uint256) -> bool:
    assert self.token_approval[sender][msg.sender] >= amount, "You are not allowed to transfer this amount"
    assert self.token_library[sender] >= amount, "Funds are insufficeint from Sender"
    self.token_library[sender] -= amount
    self.token_library[receiver] = self.token_library[receiver] + amount
    # This will reduce the allowance amount from approved addresses
    self.token_approval[sender][msg.sender] -= amount
    log Transfer_completed(sender, receiver, amount)
    return True

@external
def transfer(to: address, amount: uint256) -> bool:
    assert self.token_library[msg.sender] >= amount, "Funds are insufficient for transaction"
    self.token_library[msg.sender] -= amount
    self.token_library[to] += amount
    log Transfer_completed(msg.sender, to, amount)
    return True

@external
def mint_token(to: address, amount: uint256) -> bool:
    assert msg.sender == self.owner, "You don't have access to this function"
    assert amount <= (TOKEN_AMOUNT - self.moving_token), "You can't mint more than total supply"
    self.moving_token += amount
    self.token_library[to] += amount
    log Token_minted(to, amount, self.moving_token)
    return True





