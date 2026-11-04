// § macroIfaceRangeSelBaseTok256 (a concatenation target holding the select, macro body)
`define conn(FIF) \
  assign  {FIF.read_data[0+:4], y} = x;
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [4:0] x; logic y;
  `conn(bi)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
