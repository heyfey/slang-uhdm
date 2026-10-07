// § sysCallTimeKwNameSpan270
`define NOW $time()
`define NOWR(x) (x + $realtime())
package p;
  class c;
    time t;
    realtime r;
    function void f();
      t = `NOW;
      r = `NOWR(1.0);
      t = $time(
      );
    endfunction
  endclass
endpackage
module top;
  import p::*;
  c x;
endmodule
