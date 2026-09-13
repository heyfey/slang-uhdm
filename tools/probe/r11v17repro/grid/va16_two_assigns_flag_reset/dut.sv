// TWO cont-assigns in ONE gen block: the first has a BOUND module Lhs with an
// operation Rhs (law fires), the second a GEN-LOCAL Lhs (law must stand down).
// Convicts a flag that leaks across assignments.
module top(input logic [31:0] a, input logic [31:0] b, output logic [31:0] o, output logic [31:0] o2);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    logic [31:0] loc;
    assign src = a;
    assign mv  = src | 32'd1;
    assign loc = src ^ b;
    assign o2  = loc;
  end
  assign o = mv;
endmodule
