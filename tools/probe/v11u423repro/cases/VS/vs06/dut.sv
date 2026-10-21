// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'b101;
  function automatic int g(int a);
    return a + H;
  endfunction
endpackage
module top(input int x, output int y);
  import p::*;
  assign y = g(x);
endmodule
