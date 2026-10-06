// § macroIfaceRangeSelBaseTok256 (the read on the right side in a macro body (control))
`define rd(FIF, LSB) \
  assign  x = FIF.read_data[LSB+:4];
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  `rd(bi, 4)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
