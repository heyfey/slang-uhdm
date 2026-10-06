// § dupImportSameValueKeeps252
package p;
parameter A = 3;
class cfg #(int N = 1);
  localparam int W = N * 2;
endclass
endpackage
import p::*;
module top(output logic [cfg#(A)::W-1:0] o);
  assign o = '1;
endmodule
