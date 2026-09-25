// § defaultFillImportCopies145
package pack;
localparam int unsigned V[3] = '{default: 5};
endpackage
module top(output int o);
import pack::V;
assign o = V[2];
endmodule
