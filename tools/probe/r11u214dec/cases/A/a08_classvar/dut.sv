// § enumTdLastWriter214 — an enum alias typedef as a package class's variable type, no importer
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  class c;
    ALIAS_T m;
  endclass
endpackage
