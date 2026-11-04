// § unitHoistBindsSysCallRhs462
package p; parameter int N = $bits(int); endpackage
package q; import p::*; parameter int M = N + 1; endpackage
import q::*;
module top; endmodule
