// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
import p::*;
class C;
  extern function int m();
endclass
function int C::m(); return 1; endfunction
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  C c = new;
  initial r = F(1) + pf(2) + c.m();
endmodule
