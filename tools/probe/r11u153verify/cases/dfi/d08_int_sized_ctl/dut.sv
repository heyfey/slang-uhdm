// law defaultFillImportIntOnly153v (control)
package pack;
parameter int V[2] = '{default: 32'd5};
endpackage
module top(output int o);
import pack::*;
assign o = 1;
endmodule
