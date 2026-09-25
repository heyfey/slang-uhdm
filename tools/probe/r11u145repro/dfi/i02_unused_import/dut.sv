// § defaultFillImportCopies145
package pack;
parameter int V[2] = '{default: 5};
endpackage
module top(output int o);
import pack::*;
assign o = 1;
endmodule
