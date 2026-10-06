// § genChildParentAtBirth261
module leaf (input logic [31:0] d, input logic [3:0] k, output logic [15:0] o);
  assign o = d[31:16] ^ {12'h0, k[3:0]};
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o, output logic [15:0] p);
  if (B) begin : g_b
    leaf l1 (.d(d), .k(d[3:0]), .o(o));
    leaf l2 (d, d[7:4], p);
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o, p;
  mid m (.d(d), .o(o), .p(p));
endmodule
