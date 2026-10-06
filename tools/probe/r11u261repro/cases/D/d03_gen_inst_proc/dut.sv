// § genChildParentAtBirth261
module leaf (input logic clk, input logic [31:0] d, output logic [15:0] o);
  logic [15:0] q;
  always_ff @(posedge clk) q <= d[15:0];
  always_comb o = q[15:8] == 8'h0 ? d[31:16] : q;
endmodule
module mid #(parameter bit B = 1) (input logic clk, input logic [31:0] d, output logic [15:0] o);
  if (B) begin : g_b
    leaf l (.clk(clk), .d(d), .o(o));
  end else begin : g_n
    assign o = '0;
  end
endmodule
module top;
  logic clk; logic [31:0] d; logic [15:0] o;
  mid m (.clk(clk), .d(d), .o(o));
endmodule
