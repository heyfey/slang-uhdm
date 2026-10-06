// § dupImportSameValueKeeps252
package p;
parameter int A = 37;
parameter int W = $clog2(A);
function automatic int f(int x); return x * 2 + 1; endfunction
parameter int F = f(3);
parameter int T = (A > 10) ? 1 : 0;
endpackage
import p::*;
module top(output logic [W-1:0] o, output logic [7:0] o2);
  assign o = W'(F);
  assign o2 = 8'(T);
endmodule
