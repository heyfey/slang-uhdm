// § newLhsSelCgCopyAtIndex437
package p;
class C; int v; endclass
endpackage
module top;
p::C c[2];
initial begin c[0] = new; c[1] = new c[0]; end
endmodule
