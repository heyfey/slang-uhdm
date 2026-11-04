// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg(int w); coverpoint a; endgroup
cg cs[2];
initial begin cs[1] = new(5); end
endmodule
