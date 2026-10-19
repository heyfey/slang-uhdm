// § oobCtorHoistSourceOrder403
package p;
class A;
  extern function new();
endclass
class B extends A;
  extern function new();
endclass
function B::new();
  int rb;
  super.new();
  rb = 1;
endfunction
function A::new();
  int ra;
  ra = 2;
endfunction
int tail_v;
endpackage
module top; endmodule
