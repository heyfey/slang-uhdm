package vla19;   // class METHOD iterating a PACKAGE variable; module wildcard-imports
  int pv19[string];
  class cl19;
    extern function void mf19();
  endclass
  function void cl19::mf19();
    foreach (pv19[i]) $display("m", pv19[i]);
    pv19["a"] = 1;
  endfunction
endpackage
package vlb19;   // same, but NOBODY imports the package
  int qv19[string];
  class cm19;
    extern function void nf19();
  endclass
  function void cm19::nf19();
    foreach (qv19[i]) $display("n", qv19[i]);
    qv19["b"] = 2;
  endfunction
endpackage
module mla19; import vla19::*; initial begin vla19::cl19 h=new(); h.mf19(); end endmodule
module vtopl19; mla19 u(); endmodule
