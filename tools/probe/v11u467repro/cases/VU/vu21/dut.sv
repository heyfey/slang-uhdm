// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*;
  localparam int CL = PA + 2;
endpackage
import c::*;
module top;
  logic w;
endmodule
