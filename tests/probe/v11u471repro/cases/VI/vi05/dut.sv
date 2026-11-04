// § pkgInitImpReadFolds471
// two importers of a both reading PA; a module reads both
package a;
  parameter logic [7:0] PA = 8'd20;
endpackage
package b;
  import a::*;
  localparam logic [7:0] LB = PA + 8'd1;
endpackage
package c;
  import a::PA;
  localparam logic [7:0] LC = PA - 8'd1;
endpackage
module top(output logic [7:0] y);
  import b::*;
  import c::*;
  assign y = LB ^ LC;
endmodule
