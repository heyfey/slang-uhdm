// § genLoopDirectBoundPaCopy280
// the bound in an always_comb in a for-generate beside a continuous assignment
module top (input logic [31:0] sig, output logic [1:0] o [2], output logic [1:0] p [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb p[i] = sig[R4 +: 2];
    assign o[i] = sig[R4 -: 2];
  end
endmodule
