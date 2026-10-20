// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
import p::pf;
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial r = F(1) + pf(2);
endmodule
