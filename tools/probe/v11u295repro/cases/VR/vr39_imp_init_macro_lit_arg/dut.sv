// § rawEndLineModel295
`define LIT(x) x
package p;
  logic [7:0] v = `LIT(8'h3);
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
