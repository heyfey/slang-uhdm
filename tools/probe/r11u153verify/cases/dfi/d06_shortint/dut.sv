// law defaultFillImportIntOnly153v
package pack;
parameter shortint V[2] = '{default: 3};
endpackage
module top(output int o);
import pack::*;
assign o = 1;
endmodule
