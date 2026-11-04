// § defaultFillImportCopies145
package pack;
parameter int V[3] = '{default: 7};
endpackage
module top(output int o);
import pack::*;
always_comb o = V[1];
endmodule
