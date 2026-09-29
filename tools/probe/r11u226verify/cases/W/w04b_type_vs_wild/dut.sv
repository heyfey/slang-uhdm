// § enumTdLastWriter214 § enumPkgWriterImportsType219 — package zq imports the type by name, package aq wildcard, module importer none: the last package writer in dependency order
package p;
  typedef enum logic [1:0] {V0, V1, V2} val_e;
  typedef val_e VAL_T;
endpackage
package zq;
  import p::VAL_T;
  function automatic int fz(VAL_T v); return int'(v); endfunction
endpackage
package aq;
  import p::*;
  function automatic int fa(VAL_T v); return int'(v) + 1; endfunction
endpackage
module top(output int o);
  assign o = zq::fz(p::V2) + aq::fa(p::V1);
endmodule
