// § genChildParentAtBirth261
module leaf (input logic [31:0] d, input logic [1:0] s, output logic [7:0] o, output logic [7:0] p);
  assign o = d[s*8 +: 8];
  assign p = d[31 -: 8];
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, input logic [1:0] s, output logic [7:0] o, output logic [7:0] p);
  if (B) begin : g_b
    leaf l (.d(d), .s(s), .o(o), .p(p));
  end
endmodule
module top;
  logic [31:0] d; logic [1:0] s; logic [7:0] o, p;
  mid m (.d(d), .s(s), .o(o), .p(p));
endmodule
