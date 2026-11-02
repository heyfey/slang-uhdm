// § unitHoistBindsSysCallRhs462
package p; parameter int N = 16; parameter int L = $clog2(N); endpackage
import p::*;
module top; logic [L-1:0] x; assign x = L; endmodule
