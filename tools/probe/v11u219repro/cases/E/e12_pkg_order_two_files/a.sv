// § enumTdLastWriter214 — the home package and a late-named importer in the first file
package p;
  typedef enum logic [1:0] {T0, T1} t_t;
  typedef t_t ALIAS_T;
endpackage
package yq;
  import p::*;
  function automatic ALIAS_T fy(ALIAS_T v); return v; endfunction
endpackage
