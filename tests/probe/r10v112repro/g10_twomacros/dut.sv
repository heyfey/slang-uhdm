// g10 — THE MiniAmiq SHAPE WITHOUT UVM: two DIFFERENT macros expanding to a
// typedef of the SAME foreign generic, interleaved, plus a `_param` variant
// that passes only ONE argument.  If the group key were the macro's
// file:line:col the two macros would form two groups; the law says ONE group
// keyed on the target generic class.
`define reg_full(T) typedef B10 #(T,"T") type_id
`define reg_param(T) typedef B10 #(T) type_id
package p10box;
  class B10 #(type Q = int, string Nm = "?"); int x10; endclass
endpackage
package p10use;
  import p10box::*;
  class Aa10;  `reg_full(Aa10);  endclass
  class bb10;  `reg_param(bb10); endclass
  class cc10;  `reg_full(cc10);  endclass
  class dd10;  `reg_param(dd10); endclass
endpackage
