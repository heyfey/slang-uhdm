// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
module top;
C c[4];
int i = 1;
initial begin c[i+1] = new; c[(i)] = new; end
endmodule
