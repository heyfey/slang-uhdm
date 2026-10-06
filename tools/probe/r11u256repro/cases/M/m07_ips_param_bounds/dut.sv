// § macroIfaceRangeSelBaseTok256 (parameter base and width in a macro body (constant slots))
`define conn(FIF, LSB, WIDTH) \
  assign  FIF.read_data[LSB+:WIDTH] = x;
interface bif; logic [15:0] read_data; endinterface
module m #(parameter int L = 2, parameter int W = 3)(bif bi); logic [W-1:0] x;
  `conn(bi, L*2, W)
endmodule
module top; bif b(); m #(.L(1), .W(5)) u(.bi(b)); endmodule
