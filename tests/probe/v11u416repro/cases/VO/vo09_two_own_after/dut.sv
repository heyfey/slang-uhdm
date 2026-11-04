// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
  task pt; endtask
endpackage
import p::*;
function int F(int y);
  F = y;
endfunction
function int G(int y);
  G = F(y);
endfunction
module top;
  int r;
  initial begin pt(); r = G(1) + pf(2); end
endmodule
