// § dupImportSameValueKeeps252
package p;
typedef logic [5:0] w_t;
parameter N = $bits(w_t);
parameter M = $bits(logic [7:0]) + 1;
localparam L = N * 2;
endpackage
import p::*;
module top(output logic [N-1:0] o, output logic [7:0] o2);
  assign o = '1;
  assign o2 = M + L;
endmodule
