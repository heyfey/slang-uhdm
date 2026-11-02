// § pkgInitImpReadFolds471
// read through a chain (b exports a, c imports b only): not a direct import
package a;
  parameter int PA = 4;
endpackage
package b;
  import a::*;
  localparam int LB = PA;
  export a::*;
endpackage
package c;
  import b::*;
  localparam int LC = PA * 2;
endpackage
module top(output int y);
  import c::*;
  assign y = LC;
endmodule
