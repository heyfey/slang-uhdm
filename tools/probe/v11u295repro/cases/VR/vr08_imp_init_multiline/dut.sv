// § rawEndLineModel295
package p;
  logic [7:0] v = {4'h1,
    4'h2};
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
