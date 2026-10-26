// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[4];
initial for (int i = 0; i < 3; i++) cs[i+1] = new();
endmodule
