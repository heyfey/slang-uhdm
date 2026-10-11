// § genProcUnaryFoldInst282
module top (input logic [31:0] a [2], output logic [31:0] z [2]);
  localparam int unsigned P = 32'hF0;
  if (1) begin : g localparam int w = 0;
    always_comb z[w] = ~P;
  end
endmodule
module wrap(input logic [31:0] a [2], output logic [31:0] z [2]); top u (.a(a), .z(z)); endmodule
