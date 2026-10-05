// § unitTdLawS245
// a header of $unit typedefs included once, used by two modules at the same positions
`include "td.svh"
module m1;
  hi_t a;
  hv_t b;
endmodule
module top;
  hi_t a;
  hv_t b;
  m1 u();
endmodule
