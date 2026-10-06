// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  assign o = d[31:16] ^ d[15:0];
endmodule
module mid2 (input logic [31:0] d, output logic [15:0] o);
  leaf l2 (.d(d), .o(o));
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o);
  if (B) begin : g_b
    mid2 u (.d(d), .o(o));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
