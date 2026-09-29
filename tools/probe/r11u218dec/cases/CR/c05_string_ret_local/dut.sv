// § importCloneSharesHomeReturn218 — c05_string_ret_local: a string return with a local variable
package p1;
  class c;
    extern function string f();
  endclass
  function string c::f();
    string t;
    t = "x";
    return t;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
