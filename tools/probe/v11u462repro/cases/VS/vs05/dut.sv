// § unitHoistBindsSysCallRhs462
package p; parameter logic [3:0] A = 4'h3; parameter int S = $size(A); parameter int B = $bits(A) + 1; endpackage
import p::*;
module top; logic [S:0] x; logic [B:0] y; endmodule
