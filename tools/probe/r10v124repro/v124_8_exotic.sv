// r10v124 arm 8 — EXOTIC receivers kept apart so a rejection cannot mask the
// rest: a CALL-RESULT receiver and a RANGED part-select.
package Cellar;
  typedef int Vat[$];
  class Barrel;
    Vat Casks[4];
    Vat Tuns[string];
    function Vat draw(); return Casks[0]; endfunction
    function void pour(string kx);
      draw().push_back(801);
      Casks[1:2].reverse();
    endfunction
  endclass
endpackage
module Vault2;
  Cellar::Barrel bl;
  initial begin bl = new(); bl.pour("z"); end
endmodule
