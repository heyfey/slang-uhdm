// § macroIfaceRangeSelBaseTok256 (an include-born macro used from the other root file)
`include "defs.svh"
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module ma(bif bi); logic [3:0] x;
  `conn(bi, 0)
endmodule
