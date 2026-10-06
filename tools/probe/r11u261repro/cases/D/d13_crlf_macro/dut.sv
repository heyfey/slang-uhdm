// § genChildParentAtBirth261
`define HI(x) x[31:16]
module leaf (input logic [31:0] d, output logic [15:0] o);
  assign o = `HI(d) ^ d[15:0];
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
