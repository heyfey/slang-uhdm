// § rawEndLineModel295
`define HI 1
package p;
  logic [7:0] v [`HI:0];
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
