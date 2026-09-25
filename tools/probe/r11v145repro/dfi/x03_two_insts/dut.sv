// § defaultFillImportCopies145
package pack;
localparam logic [3:0] V[2] = '{default: 4'hA};
endpackage
module child #(parameter int K = 0) (output logic [3:0] o);
import pack::*;
assign o = V[K];
endmodule
module top(output logic [3:0] a, output logic [3:0] b);
child #(0) u0(a);
child #(1) u1(b);
endmodule
