// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
  function int pg(int a); return a; endfunction
endpackage
import p::*;
function int pg(int y);
  pg = y + 1;
endfunction
module top;
  int r;
  initial r = pg(1) + pf(2);
endmodule
