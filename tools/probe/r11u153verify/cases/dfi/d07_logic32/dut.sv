// law defaultFillImportIntOnly153v
package pack;
parameter logic [31:0] V[2] = '{default: 5};
endpackage
module top(output int o);
import pack::*;
assign o = 1;
endmodule
