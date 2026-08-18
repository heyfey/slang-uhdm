// vbuvm19 — WHAT MAKES THE PACKAGE-VARIABLE CELL FLIP.
package vja19;                       // (a) imported by an UNINSTANTIATED module
  int av19[string];
  function void af19();
    foreach (av19[i]) $display("a", av19[i]);
    av19["a"] = 1;
  endfunction
endpackage
package vjb19;                       // (b) imported by an INSTANTIATED module
  int bv19[string];
  function void bf19();
    foreach (bv19[i]) $display("b", bv19[i]);
    bv19["b"] = 2;
  endfunction
endpackage
package vjc19;                       // (c) not imported by anything
  int cv19[string];
  function void cf19();
    foreach (cv19[i]) $display("c", cv19[i]);
    cv19["c"] = 3;
  endfunction
endpackage
package vjd19;                       // (d) EXPLICIT import by an instantiated module
  int dv19[string];
  function void df19();
    foreach (dv19[i]) $display("d", dv19[i]);
    dv19["d"] = 4;
  endfunction
endpackage
package vje19;                       // (e) CLASS PROPERTY, module wildcard-imports
  class ce19; int ev19[string];
    extern function void ef19();
  endclass
  function void ce19::ef19();
    foreach (ev19[i]) $display("e", ev19[i]);
    ev19["e"] = 5;
  endfunction
endpackage
module mja19; import vja19::*; initial af19(); endmodule      // never instantiated
module mjb19; import vjb19::*; initial bf19(); endmodule
module mjd19; import vjd19::df19; initial df19(); endmodule
module mje19; import vje19::*; initial begin vje19::ce19 h; h = new(); h.ef19(); end endmodule
module vtopj19;
  mjb19 ub();
  mjd19 ud();
  mje19 ue();
endmodule
