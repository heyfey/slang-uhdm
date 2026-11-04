// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
  parameter int PZ = 2;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PZ; endpackage
package d; import a::*; import b::*; export a::PZ; endpackage
import c::*;
import d::*;
module top(output logic [31:0] o);
  assign o = PZ;
endmodule
