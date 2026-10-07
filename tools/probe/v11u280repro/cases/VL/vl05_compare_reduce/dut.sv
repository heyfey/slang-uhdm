// § genLoopDirectBoundPaCopy280
// the select in a comparison, a reduction and a negation under a plain left side
module top (input logic [31:0] sig, output logic o [2], output logic p [2], output logic [1:0] q [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2] == 2'b01;
    assign p[i] = &sig[R4 +: 2];
    assign q[i] = -sig[R4 +: 2];
  end
endmodule
