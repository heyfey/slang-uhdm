// § enumTdLastWriter214 — an importing package's clone of a home-package class method whose formal is typed by an enum alias (the UVM set_arbitration shape)
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c;
  endclass
endpackage
