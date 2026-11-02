// § unitHoistBindsSysCallRhs462
package p; typedef enum logic [1:0] {A,B} e; typedef struct packed {logic [7:0] a; e b;} s; parameter int N = $bits(s); typedef logic [N-1:0] w_t; parameter int M = N - 1; endpackage
import p::*;
module top; w_t x; endmodule
