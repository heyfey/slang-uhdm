// § macroIfaceRangeSelBaseTok256 (a simple part select in a macro body)
`define conn(FIF) \
  assign  FIF.read_data[5:2] = x;
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  `conn(bi)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
