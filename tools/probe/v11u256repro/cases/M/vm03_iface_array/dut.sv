// § macroIfaceRangeSelBaseTok256 (an interface array element base in the macro)
`define conn(FIF, LSB) \
  assign FIF[1].read_data[LSB+:4] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m; logic [3:0] x; bif bb[2]();
  `conn(bb, 0)
endmodule
module top; m u(); endmodule
