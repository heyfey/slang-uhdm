// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
function int F1(int y);
  F1 = y;
endfunction
import p::*;
function int F2(int y);
  F2 = y;
endfunction
module top;
  int r;
  initial r = F1(1) + F2(2) + pf(3);
endmodule
