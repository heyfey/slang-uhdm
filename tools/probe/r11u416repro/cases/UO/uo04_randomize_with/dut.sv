// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
import p::*;
class a; rand int x; endclass
function int F(a obj, int y);
  F = obj.randomize() with { x > 0; x < y; };
endfunction
module top;
  int r;
  a o = new;
  initial r = F(o, 1);
endmodule
