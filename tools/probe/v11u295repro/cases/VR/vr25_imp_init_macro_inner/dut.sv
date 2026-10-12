// § rawEndLineModel295
`define INNER 8'h3
`define OUTER (`INNER)
package p;
  logic [7:0] v = `OUTER;
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
