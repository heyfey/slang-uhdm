// § unitImportTfSourceOrder416
package p;
  function int pf(int a); return a; endfunction
endpackage
function int F(int y);
  F = y;
endfunction
module top;
  import p::*;
  int r;
  initial r = F(1) + pf(2);
endmodule
