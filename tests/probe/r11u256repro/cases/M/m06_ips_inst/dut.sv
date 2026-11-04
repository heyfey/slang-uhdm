// § macroIfaceRangeSelBaseTok256 (an interface instance (not a port) in a macro body)
`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB+:2] = x;
interface bif; logic [7:0] read_data; endinterface
module top; bif b(); logic [1:0] x;
  `conn(b, 4)
endmodule
