// § tpUseBindsDefDefault160
typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
module leaf #(parameter type dtype = d_t) (input logic clk, input dtype data_i, output dtype data_o);
  dtype q;
  always_ff @(posedge clk) q <= data_i;
  assign data_o = q;
endmodule
module top (input logic clk, input d_t a, output d_t b, output d_t c);
  leaf u1 (.clk(clk), .data_i(a), .data_o(b));
  leaf u2 (.clk(clk), .data_i(a), .data_o(c));
endmodule
