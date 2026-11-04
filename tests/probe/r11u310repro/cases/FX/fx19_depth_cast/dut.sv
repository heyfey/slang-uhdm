// § castTsLvIdxByChain310
typedef struct packed { logic [3:0] k; logic [3:0][7:0] w; } e_t;
module leaf(input logic clk, input logic [1:0] i, input logic [7:0] d, output e_t m);
  always_ff @(posedge clk) begin m.w[2'(i)] <= d; m.w[int'(i) + 1] <= d; end
endmodule
module mid(input logic clk, input logic [1:0] i, input logic [7:0] d, output e_t m);
  leaf l(.clk(clk), .i(i), .d(d), .m(m));
endmodule
module top(input logic clk, input logic [1:0] i, input logic [7:0] d, output e_t m);
  mid u(.clk(clk), .i(i), .d(d), .m(m));
endmodule
