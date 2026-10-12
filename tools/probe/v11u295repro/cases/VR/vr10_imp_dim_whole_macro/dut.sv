// § rawEndLineModel295
`define DIM [1:0]
package p;
  logic [7:0] v `DIM;
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
