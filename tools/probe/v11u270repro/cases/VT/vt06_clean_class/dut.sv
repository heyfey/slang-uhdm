// § sysCallTimeKwNameSpan270
`define NOW $time()
package p;
  class c;
    longint t;
    real r;
    function void f();
      t = `NOW;
      r = $realtime() + 1.0;
      t = $time(
      );
      t = {$time()};
      $display("%0t", $time());
    endfunction
  endclass
endpackage
module top;
  import p::*;
  c x;
endmodule
