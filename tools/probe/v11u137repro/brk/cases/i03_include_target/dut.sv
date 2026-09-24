// § aliasCloneTakesTargetFile137
`include "s.svh"
module dut(output o);
  typedef s_t sa [2];
  sa v;
  assign v[0].x = 1'b1;
  assign o = v[0].x;
endmodule
