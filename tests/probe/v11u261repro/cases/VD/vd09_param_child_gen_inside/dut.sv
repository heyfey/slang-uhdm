// § genChildParentAtBirth261
module leaf #(parameter int N = 2) (input logic [31:0] d, output logic [15:0] o [N]);
  for (genvar j = 0; j < N; j++) begin : inner
    assign o[j] = d[16*j +: 16];
  end
endmodule
module mid (input logic [31:0] d, output logic [15:0] o [2]);
  if (1) begin : g
    leaf #(.N(2)) l (.d(d), .o(o));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o [2];
  mid m (.d(d), .o(o));
endmodule
