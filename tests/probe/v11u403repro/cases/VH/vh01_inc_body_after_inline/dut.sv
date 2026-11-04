// § oobCtorHoistSourceOrder403
package p;
class A; extern function new(); endclass
class B; extern function new(); endclass
class C; extern function new(); endclass
function C::new(); int c1; c1 = 1; endfunction
`include "a_body.svh"
function B::new(); int b1; b1 = 2; endfunction
endpackage
module top; endmodule
