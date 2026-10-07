// § genLoopDirectBoundPaCopy280
// a child whose parameter is overridden with a replication value, the bound in its for-generate
module kid #(parameter logic [3:0] R4 = 4'd0) (input logic [31:0] sig, output logic [1:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2];
  end
endmodule
module top (input logic [31:0] sig, output logic [1:0] o [2], output logic [1:0] p [2]);
  kid #(.R4({2{2'b01}})) u0 (.sig(sig), .o(o));
  kid u1 (.sig(sig), .o(p));
endmodule
