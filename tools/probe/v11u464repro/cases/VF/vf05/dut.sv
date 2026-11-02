// § unitImpTfNameDedup464 (two packages each with an out-of-body method C::m)
package p1;
  class C; extern function int m(int x); endclass
  function int C::m(int x); return x; endfunction
endpackage
package p2;
  class C; extern function int m(int x); endclass
  function int C::m(int x); return x + 1; endfunction
endpackage
import p1::*;
import p2::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
