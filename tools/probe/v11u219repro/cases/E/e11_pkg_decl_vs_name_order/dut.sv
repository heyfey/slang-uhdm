// § enumTdLastWriter214 — two importing packages declared against their name order (zq before aq), no module imports the home package: which package writes last
package p;
  typedef enum logic [1:0] {R0, R1, R2} r_t;
  typedef r_t ALIAS_T;
endpackage
package zq;
  import p::*;
  function automatic ALIAS_T fz(ALIAS_T v); return v; endfunction
endpackage
package aq;
  import p::*;
  function automatic ALIAS_T fa(ALIAS_T v); return v; endfunction
endpackage
module top(output int o);
  import zq::*;
  import aq::*;
  assign o = 0;
endmodule
