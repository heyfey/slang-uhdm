// § exportDupKeepsDiamondPaths471v
// diamond (c imports a and b, b imports a) plus an explicit export; module body imports c
package a;
  parameter int PA = 1;
  parameter int PZ = 2;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PZ; endpackage
module top(output int o);
  import c::*;
  assign o = PZ;
endmodule
