// § genChildParentAtBirth261
module leaf (input logic clk, input logic [31:0] d, output logic [15:0] o);
  always_ff @(posedge clk) o <= d[31:16] + d[15:0];
endmodule
module mid (input logic clk, input logic [31:0] d, output logic [15:0] o);
  case (2)
    1: begin : c1 assign o = '0; end
    2: begin : c2 leaf l (.clk(clk), .d(d), .o(o)); end
  endcase
endmodule
module top;
  logic clk; logic [31:0] d; logic [15:0] o;
  mid m (.clk(clk), .d(d), .o(o));
endmodule
