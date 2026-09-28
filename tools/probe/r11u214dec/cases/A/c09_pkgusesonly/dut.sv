// § enumTdLastWriter214 — a package using p::ALIAS_T by its qualified name without importing
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
package q;
  p::ALIAS_T qv;
endpackage
