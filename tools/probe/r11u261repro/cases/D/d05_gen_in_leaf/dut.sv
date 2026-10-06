// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  if (1) begin : g_in
    assign o = d[31:16];
  end
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o);
  if (B) begin : g_b
    leaf l (.d(d), .o(o));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
