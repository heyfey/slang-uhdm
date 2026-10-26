// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[];
initial begin c = new[2]; c[0] = new; c[1] = new c[0]; end
endmodule
