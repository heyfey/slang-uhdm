// § macroIfaceRangeSelBaseTok256 (a nested macro: the outer macro passes the path to the inner one)
`define inner(FIF, LSB) \
  assign  FIF.read_data[LSB+:4] = x;
`define outer(P) `inner(P, 4)
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  `outer(bi)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
