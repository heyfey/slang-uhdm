// § newLhsSelCgCopyAtIndex437
class C; int v; endclass
package p;
class D; int v; endclass
function automatic void f(); D d[2]; d[0] = new; endfunction
endpackage
module top;
task automatic t(); C c[2]; c[1] = new; endtask
initial t();
endmodule
