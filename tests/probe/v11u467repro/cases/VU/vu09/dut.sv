// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PA; endpackage
import c::*;
module top(output logic [7:0] o);
  sub #(.W(PA+3)) u(.o(o));
endmodule
module sub #(parameter int W = 2)(output logic [7:0] o);
  assign o = W;
endmodule
