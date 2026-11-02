// § unitCopyOwnTsEveryPath467
package a;
  localparam int LA = 5;
  parameter logic [7:0] PV = 8'h3c;
  parameter string PS = "hi";
  parameter real PR = 1.5;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
import c::*;
module top;
  logic w;
endmodule
