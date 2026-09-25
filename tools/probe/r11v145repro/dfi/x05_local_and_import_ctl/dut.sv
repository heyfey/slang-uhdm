// § defaultFillImportCopies145
package pack;
localparam int V[2] = '{default: 2};
endpackage
module top(output int o, output int p);
import pack::*;
localparam int L[2] = '{default: 9};
assign o = V[1];
assign p = L[1];
endmodule
