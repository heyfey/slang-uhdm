// § lpPaCopyBoundOwnerName145
module c #(parameter int W = 8) (input logic [63:0] a, output logic [63:0] o);
  localparam int L = W/2;
  if (W > 4) begin : g
    assign o[63:L] = a[63:L];
  end
endmodule
module dut(input logic [63:0] a, output logic [63:0] x, output logic [63:0] y);
  c #(16) u0(a, x);
  c u1(a, y);
endmodule
