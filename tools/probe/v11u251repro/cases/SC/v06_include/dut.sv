// § ppStrEndNotTokStart251 (the stringifying macro defined in an included header)
`include "m.svh"
module top;
  int x;
  initial `D(abcde)
endmodule
