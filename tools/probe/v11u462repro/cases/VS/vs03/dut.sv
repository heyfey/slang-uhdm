// § unitHoistBindsSysCallRhs462
package p; typedef struct packed {logic [7:0] a; logic b;} s; parameter int N = $bits(s); endpackage
import p::*;
module top #(parameter int N = 3) (); logic [N-1:0] x; endmodule
