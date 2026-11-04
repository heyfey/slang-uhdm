// § unitImportTfSourceOrder416
package p1;
  function int f1(int a); return a; endfunction
endpackage
package p2;
  function int f2(int a); return a; endfunction
endpackage
import p1::*, p2::*;
function int F(int y);
  F = y;
endfunction
module top;
  int r;
  initial r = F(1) + f1(2) + f2(3);
endmodule
