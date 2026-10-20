// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
task T;
endtask
import p::*;
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial begin T(); r = F(1) + pf(2); end
endmodule
