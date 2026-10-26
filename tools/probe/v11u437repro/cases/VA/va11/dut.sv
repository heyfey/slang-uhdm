// § newLhsSelCgCopyAtIndex437
`define IX 1
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial cs[`IX] = new();
endmodule
