// § unitHoistBindsSysCallRhs462
package p; typedef struct packed {logic [6:0] a; logic b;} s; parameter int N = $bits(s); parameter int M = N + 1; endpackage
import p::*;
module top(input logic [M-1:0] i, output logic [M-1:0] o); assign o = i + N; endmodule
