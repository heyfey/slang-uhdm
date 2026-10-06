// § dupImportSameValueKeeps252
package p;
localparam N = 12;
parameter A = $clog2(N);
parameter B = N/4 + 1;
parameter C = (N > 4) ? N - 1 : 2;
parameter D = 4'(N);
endpackage
import p::*;
module top; endmodule
