// § macroIfaceRangeSelBaseTok256 (instance depth 3 with the macro select at the leaf)
`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB+:4] = x;
interface bif; logic [7:0] read_data; endinterface
module leaf(bif bi); logic [3:0] x;
  `conn(bi, 4)
endmodule
module mid(bif bi); leaf l(.bi(bi)); endmodule
module top; bif b(); mid u(.bi(b)); endmodule
