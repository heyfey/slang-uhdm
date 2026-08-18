package vka19;   // wildcard-imported at $unit scope
  int av19[string];
  function void af19();
    foreach (av19[i]) $display("a", av19[i]);
    av19["a"] = 1;
  endfunction
endpackage
package vkb19;   // wildcard-imported by an INTERFACE
  int bv19[string];
  function void bf19();
    foreach (bv19[i]) $display("b", bv19[i]);
    bv19["b"] = 2;
  endfunction
endpackage
package vkc19;   // wildcard-imported by a module; the cell is a FORMAL
  function automatic void cf19(ref int cq19[$]);
    foreach (cq19[i]) $display("c", cq19[i]);
    cq19[0] = 1;
  endfunction
  int cdummy19[string];
endpackage
package vkd19;   // wildcard-imported by a module; the cell is a subroutine LOCAL
  function void df19();
    int dl19[string];
    foreach (dl19[i]) $display("d", dl19[i]);
    dl19["d"] = 4;
  endfunction
  int ddummy19[string];
endpackage
package vke19;   // wildcard-imported by a PROGRAM
  int ev19[string];
  function void ef19();
    foreach (ev19[i]) $display("e", ev19[i]);
    ev19["e"] = 5;
  endfunction
endpackage
import vka19::*;
interface ikb19; import vkb19::*; endinterface
module mkc19; import vkc19::*; int q19[$]; initial cf19(q19); endmodule
module mkd19; import vkd19::*; initial df19(); endmodule
program pke19; import vke19::*; initial ef19(); endprogram
module vtopk19; mkc19 uc(); mkd19 ud(); ikb19 ui(); endmodule
