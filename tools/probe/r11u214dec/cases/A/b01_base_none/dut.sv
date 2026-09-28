// § enumTdLastWriter214 — an enum with an explicit base type and its alias, no importer
package p;
  typedef enum logic [1:0] {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    mode_e m;
    function void set(ALIAS_T val); m = val; endfunction
  endclass
endpackage
