// § exportDupKeepsDiamondPaths471v
// diamond through an exporting middle package; module imports the top of the diamond
package a;
  parameter int PA = 3;
endpackage
package b; import a::*; localparam int LB = PA; export a::PA; endpackage
package c; import a::*; import b::*; endpackage
module top(output int o);
  import c::*;
  assign o = 1;
endmodule
