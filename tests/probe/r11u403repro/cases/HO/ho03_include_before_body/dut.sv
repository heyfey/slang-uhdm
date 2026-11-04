// § oobCtorHoistSourceOrder403
package p;
class A;
  extern function new();
endclass
`include "ho03_root.svh"
function A::new();
  int ra;
  ra = 2;
endfunction
int tail_v;
endpackage
module top; endmodule
