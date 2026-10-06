// § macroIfaceRangeSelBaseTok256 (an indexed down part select, member also an argument)
`define conn(FIF, MEM, LSB) \
  assign  FIF.MEM[LSB-:4] = x;
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  `conn(bi, read_data, 7)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
