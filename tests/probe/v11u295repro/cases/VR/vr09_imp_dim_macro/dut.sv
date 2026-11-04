// § rawEndLineModel295
`define N 2
package p;
  logic [7:0] v [`N];
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
