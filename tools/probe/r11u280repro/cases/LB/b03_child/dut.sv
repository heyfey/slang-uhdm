// § genLoopDirectBoundPaCopy280
// the same in a child instance, depths 1 to 3
module leaf (input logic [31:0] sig, output logic [3:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] y;
    assign y = sig[R4 +: 4];
  end
  assign z = g[0].y;
endmodule
module mid (input logic [31:0] sig, output logic [3:0] z);
  leaf u2 (.sig(sig), .z(z));
endmodule
module top (input logic [31:0] sig, output logic [3:0] z, output logic [3:0] q);
  mid u1 (.sig(sig), .z(z));
  leaf u0 (.sig(sig), .z(q));
endmodule
