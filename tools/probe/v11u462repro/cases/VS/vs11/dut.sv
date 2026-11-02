// § unitHoistBindsSysCallRhs462
package p; typedef struct packed {logic [7:0] a; logic b;} s; parameter int N = $bits(s); parameter int M = N + 1; endpackage
import p::*;
module top; import p::*; logic [M-1:0] x; endmodule
