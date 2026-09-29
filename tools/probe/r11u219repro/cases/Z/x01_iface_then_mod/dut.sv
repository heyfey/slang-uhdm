// § enumTdLastWriter214 — an interface sorting after the module by name, both importing: the module writes last
package p;
  typedef enum {M0, M1} mode_e;
  typedef mode_e ALIAS_T;
  function automatic ALIAS_T f(ALIAS_T v); return v; endfunction
endpackage
interface zz_if;
  import p::*;
  ALIAS_T s;
endinterface
module aa(output int o);
  import p::*;
  zz_if u();
  assign o = int'(f(M1));
endmodule
