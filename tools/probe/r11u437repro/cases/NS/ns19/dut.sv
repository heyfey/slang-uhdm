// § newLhsVarSelNameSpan437
module top(input clk, input [3:0] a);
covergroup cg @(posedge clk); coverpoint a; endgroup
cg cs[2][2];
initial begin cs[0][1] = new; cs[1][0] = new(); end
endmodule
