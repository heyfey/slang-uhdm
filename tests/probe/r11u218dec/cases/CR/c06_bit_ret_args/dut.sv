// § importCloneSharesHomeReturn218 — c06_bit_ret_args: a bit return with arguments
package p1;
  class c;
    extern function bit f(int a, string b);
  endclass
  function bit c::f(int a, string b);
    return a > 0;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
