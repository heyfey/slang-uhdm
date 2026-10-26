// § newLhsSelCgCopyAtIndex437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[3];
function void mk(int k); cs[k] = new(); endfunction
initial mk(1);
endmodule
