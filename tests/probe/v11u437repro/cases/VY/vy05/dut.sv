// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial fork cs[0] = new; cs[1] = new; join
endmodule
