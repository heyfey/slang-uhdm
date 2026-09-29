// § enumTdLastWriter214 § enumPkgWriterImportsType219 — package zq imports only an enum value, package aq imports the type by name, package mq wildcard: the writer among packages in both name orders
package p;
  typedef enum logic [1:0] {V0, V1, V2} val_e;
  typedef val_e VAL_T;
endpackage
package zq;
  import p::V2;
  function automatic int fz(); return int'(V2); endfunction
endpackage
package aq;
  import p::VAL_T;
  function automatic int fa(VAL_T v); return int'(v); endfunction
endpackage
package mq;
  import p::*;
  function automatic int fm(VAL_T v); return int'(v) + 1; endfunction
endpackage
module top(output int o);
  assign o = zq::fz() + aq::fa(p::V1) + mq::fm(p::V0);
endmodule
