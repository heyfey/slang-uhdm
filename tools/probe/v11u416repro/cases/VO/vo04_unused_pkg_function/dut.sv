// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
  function int pg(int a); return a + 1; endfunction
endpackage
import p::*;
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial r = F(1);
endmodule
