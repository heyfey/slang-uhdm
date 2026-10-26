// § newLhsSelCgCopyAtIndex437
module top(input clk, input [3:0] a);
covergroup cg @(posedge clk); coverpoint a; endgroup
cg x;
initial x = new;
endmodule
