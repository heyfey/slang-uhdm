// § pkgInitImpReadFolds471
// function call argument and $bits/$clog2 over an imported parameter
package a;
  parameter int PA = 9;
endpackage
package b;
  import a::*;
  function automatic int dbl(int x); return 2 * x; endfunction
  localparam int LF = dbl(PA);
  localparam int LG = $clog2(PA) + PA;
endpackage
module top(output int y);
  import b::*;
  assign y = LF + LG;
endmodule
