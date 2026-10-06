// § macroIfaceRangeSelBaseTok256 (a modport port in a macro body)
`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB+:4] = x;
interface bif; logic [7:0] read_data; modport mp(output read_data); endinterface
module m(bif.mp bi); logic [3:0] x;
  `conn(bi, 0)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
