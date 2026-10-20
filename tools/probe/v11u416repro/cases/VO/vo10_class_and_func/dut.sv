// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
  class PC; int v; function int get(); return v; endfunction endclass
endpackage
import p::*;
class UC extends PC;
  function int get2(); return get(); endfunction
endclass
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  UC u = new;
  initial r = F(1) + pf(2) + u.get2();
endmodule
