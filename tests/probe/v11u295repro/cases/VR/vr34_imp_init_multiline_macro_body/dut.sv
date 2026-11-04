// § rawEndLineModel295
`define INIT \
  8'h3
package p;
  logic [7:0] v = `INIT;
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
