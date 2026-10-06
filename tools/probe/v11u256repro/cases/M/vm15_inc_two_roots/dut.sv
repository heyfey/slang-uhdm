// § macroIfaceRangeSelBaseTok256 (an include-born macro used from two root files)
`include "defs.svh"
module m(bif bi); logic [3:0] x;
  `conn(bi, 4)
endmodule
module top; bif b(); bif b2(); m u(.bi(b)); ma v(.bi(b2)); endmodule
