// § unitHoistBindsSysCallRhs462
package p; typedef struct packed {logic [7:0] a; logic b;} s; parameter int N = $bits(s); endpackage
import p::*;
module top; logic [N-1:0] x; initial x = N; endmodule
