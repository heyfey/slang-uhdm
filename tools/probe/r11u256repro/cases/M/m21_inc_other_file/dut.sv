// § macroIfaceRangeSelBaseTok256 (the macro defined in an include, used from the root file)
`include "defs.svh"
interface bif; logic [7:0] read_data; endinterface
module m(bif bi); logic [3:0] x;
  `conn(bi, 4)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
