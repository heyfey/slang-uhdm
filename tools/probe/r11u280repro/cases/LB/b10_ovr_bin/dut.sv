// § genLoopDirectBoundPaCopy280
// an int parameter overridden in a binary spelling, read as a bound
module leaf #(parameter int P = 2) (input logic [31:0] sig, output logic [1:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] y;
    assign y = sig[P +: 2];
  end
  assign z = g[0].y;
endmodule
module top (input logic [31:0] sig, output logic [1:0] z, output logic [1:0] q);
  leaf #(.P(4'b0010)) u0 (.sig(sig), .z(z));
  leaf #(.P(4'h3)) u1 (.sig(sig), .z(q));
endmodule
