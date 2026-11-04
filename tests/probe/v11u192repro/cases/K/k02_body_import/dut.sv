// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module sub (input logic [31:0] x, output logic [31:0] y);
  import p::*;
  assign y = x[W:0];
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  import p::*;
  assign y1 = x[W:0];
  always_comb y2 = {1'b0, x[31:W]};
  sub u (.x(x[W:0]), .y(y3));
endmodule
