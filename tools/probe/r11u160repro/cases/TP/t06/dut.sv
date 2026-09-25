// § tpUseBindsDefDefault160
typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
module top #(parameter type dtype = d_t) (input logic clk, input dtype data_i, output dtype data_o);
  dtype q;
  always_ff @(posedge clk) q <= data_i;
  assign data_o = q;
endmodule
