// § unitImportTfSourceOrder416
package p1;
  function int f1(int a); return a; endfunction
endpackage
package p2;
  function int f2(int a); return a; endfunction
endpackage
import p1::*;
function int F(int y);
  F = y;
endfunction
import p2::*;
function int G(int y);
  G = y;
endfunction
module top;
  int r;
  initial r = F(1) + G(2) + f1(3) + f2(4);
endmodule
