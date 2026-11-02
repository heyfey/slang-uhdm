// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
  parameter int PB = PA * 4;
endpackage
package b; import a::*; parameter int QB = PB + 1; endpackage
package c; import a::*; import b::*; export a::PB; endpackage
import c::*;
module top(output logic [31:0] o);
  assign o = PB;
endmodule
