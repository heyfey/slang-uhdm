// § enumTdLastWriter214 § enumPkgWriterImportsType219 — package zq imports only the ALIAS by name (listing its base enum too), package aq imports the home package by wildcard and reads the base enum
package p;
  typedef enum logic [1:0] {V0, V1, V2} val_e;
  typedef val_e VAL_T;
endpackage
package zq;
  import p::VAL_T;
  localparam int ZN = 1;
endpackage
package aq;
  import p::*;
  function automatic int fa(val_e v); return int'(v) + 1; endfunction
endpackage
module top(output int o);
  assign o = aq::fa(p::V1) + zq::ZN;
endmodule
