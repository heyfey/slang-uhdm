// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  assign o = d[31:16] ^ d[15:0];
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o [2]);
  if (B) begin : g_b
    for (genvar i = 0; i < 2; i++) begin : g_arr
      leaf l (.d(d), .o(o[i]));
    end
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o [2];
  mid m (.d(d), .o(o));
endmodule
