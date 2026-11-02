// § pkgExportItemReImports471
// diamond plus a wildcard export of the home; module body imports c
package a;
  parameter int PA = 1;
  parameter int PZ = 2;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; localparam int LC = PA; export a::*; endpackage
module top(output int o);
  import c::*;
  assign o = LC;
endmodule
