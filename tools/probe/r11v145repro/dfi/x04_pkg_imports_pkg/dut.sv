// § defaultFillImportCopies145
package pa;
localparam int V[2] = '{default: 1};
endpackage
package pb;
import pa::*;
localparam int W = V[0] + 1;
endpackage
module top(output int o);
import pb::*;
assign o = W;
endmodule
