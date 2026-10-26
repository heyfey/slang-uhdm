// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[2];
function C mk(); mk = new; endfunction
initial begin c[1] = new mk(); end
endmodule
