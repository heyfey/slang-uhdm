// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
import p::*;
function int F(int y);
  F = y;
endfunction
task T;
endtask
module top;
  int r;
  initial r = F(1);
endmodule
