// § enumTdLastWriter214 — an importing package's clone of the home package's function whose formal is typed by an enum alias
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  function automatic int use_a(ALIAS_T v);
    return int'(v);
  endfunction
endpackage
package q;
  import p::*;
  function automatic int qf(int k);
    return use_a(M1) + k;
  endfunction
endpackage
