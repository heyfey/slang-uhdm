// § defFlipUnszBasedRaw459
package p; parameter logic [11:0] D = 'h5a; endpackage
module m #(A=8)(input logic clk, output logic [11:0] y); import p::*;
  logic [11:0] r;
  always_ff @(posedge clk) r <= D;
  if (D == 12'h5a) begin : g assign y = r; end
endmodule
module top; logic c; logic [11:0] y; m u(c, y); endmodule
