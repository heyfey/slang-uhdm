// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
import p::*;
import "DPI-C" function int cf(int a);
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial r = F(1) + pf(2) + cf(3);
endmodule
