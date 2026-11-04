// § defaultFillImportCopies145
package pack;
localparam int V[3] = '{default: 11};
endpackage
module top(output int o);
import pack::*;
assign o = V[0] + V[2];
endmodule
