// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module sub (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule
module top import p::*; (input logic [31:0] x, output logic [31:0] y [2], output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.a(x[W:0]), .b(y[i]));
  end
  if (W > 1) begin : gi
    sub v (.a({1'b0, x[31:W]}), .b(z));
  end
endmodule
