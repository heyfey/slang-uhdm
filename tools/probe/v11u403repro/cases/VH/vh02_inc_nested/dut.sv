// § oobCtorHoistSourceOrder403
package p;
class A; extern function new(); endclass
class B; extern function new(); endclass
`include "outer.svh"
function A::new(); string e; int t; e = ""; t = 0; endfunction
endpackage
import p::*;
module top; endmodule
