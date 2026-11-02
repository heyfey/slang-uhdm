// § unitHoistBindsSysCallRhs462
package p; parameter logic [3:0] A [2] = '{4'h1, 4'h2}; parameter int N = $size(A); parameter int M = N + 1; endpackage
import p::*;
module top; endmodule
