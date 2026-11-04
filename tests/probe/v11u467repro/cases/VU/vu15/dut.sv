// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PA; endpackage
import c::*;
interface ifc;
  logic [PA:0] s;
endinterface
module top;
  ifc u();
endmodule
