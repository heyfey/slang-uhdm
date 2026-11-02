// § unitHoistBindsSysCallRhs462
package p; parameter int N = $clog2(32); parameter int M = $clog2(N) + N; endpackage
import p::*;
module top; localparam int K = M; endmodule
