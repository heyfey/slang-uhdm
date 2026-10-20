// § unitImportTfSourceOrder416
package q;
  function int qf(int a); return a; endfunction
endpackage
package p;
  import q::*;
  function int pf(int a); return qf(a); endfunction
endpackage
import p::*;
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial r = F(1) + pf(2);
endmodule
