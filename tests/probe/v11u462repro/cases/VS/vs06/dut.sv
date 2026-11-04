// § unitHoistBindsSysCallRhs462
package p; typedef struct packed {logic [7:0] a; logic b;} s; parameter int N = $bits(s); endpackage
import p::*;
module top; import p::N; logic [N-1:0] x; endmodule
