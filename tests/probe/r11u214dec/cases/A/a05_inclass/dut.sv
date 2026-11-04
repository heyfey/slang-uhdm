// § enumTdLastWriter214 — an enum alias typedef as a package class method's formal (in-body definition), no importer
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
