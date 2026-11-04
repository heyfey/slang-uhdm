// § seqAndOrLogOp420
module top(input logic clk, clk2, en, rst, a, b, c, d, input logic [3:0] v);
  initial begin
    expect (@(posedge clk) a and b) else $error("e");
  end
endmodule
