// § enumTdLastWriter214 — a second package imports and holds a class (the class written inside the package's write)
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
package q;
  import p::*;
  class qc;
    int x;
  endclass
endpackage
