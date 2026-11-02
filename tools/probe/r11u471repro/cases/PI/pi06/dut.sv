// § pkgInitImpReadFolds471
// CONTROL no imported read (the older module-copy face, byte-identical)
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  localparam int LB = 7;
endpackage
module top;
  import b::*;
  logic [31:0] q = LB;
  logic w;
endmodule
