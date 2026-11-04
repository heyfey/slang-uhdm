// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PA; endpackage
import c::*;
module top(output logic [31:0] o);
  assign o = PA + 1;
endmodule
