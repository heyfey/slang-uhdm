// law defaultFillImportIntOnly153v (control)
package pack;
typedef int myint;
parameter myint V[2] = '{default: 3};
endpackage
module top(output int o);
import pack::*;
assign o = 1;
endmodule
