// § newLhsSelCgCopyAtIndex437
class C; int v; function new(int a = 0); v = a; endfunction endclass
module top;
C c[2];
initial begin c[0] = new; c[1] = new(3); end
endmodule
