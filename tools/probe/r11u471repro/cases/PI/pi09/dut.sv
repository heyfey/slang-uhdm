// § pkgInitImpReadFolds471
// imported parameter in a $clog2 argument and a range
package a;
  parameter int DEPTH = 16;
endpackage
package b;
  import a::*;
  localparam int AW = $clog2(DEPTH);
  typedef logic [DEPTH-1:0] v_t;
endpackage
module top;
  logic w;
endmodule
