// § unitHoistBindsSysCallRhs462
package p; parameter int N = $clog2(64); endpackage
import p::*;
module sub; logic [N:0] y; endmodule
module top; sub u(); endmodule
