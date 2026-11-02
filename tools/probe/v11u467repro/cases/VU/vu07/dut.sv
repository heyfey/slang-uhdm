// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
  parameter int unsigned PU = 2;
  parameter bit [3:0] PB = 4'b1010;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PA; endpackage
import c::PA;
import c::*;
module top;
  logic [PA:0] w;
endmodule
