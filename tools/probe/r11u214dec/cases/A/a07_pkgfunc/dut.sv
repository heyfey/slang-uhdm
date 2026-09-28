// § enumTdLastWriter214 — an enum alias typedef as a package function's formal, no importer
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  function automatic int pf(ALIAS_T v); return int'(v); endfunction
endpackage
