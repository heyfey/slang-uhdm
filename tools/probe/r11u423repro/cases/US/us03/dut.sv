// § unszBasedPkgFoldUnsized423
package p;
  parameter R = 'hf000000;
endpackage
module top(input int x, output int y);
  import p::*;
  function int f(int a);
    return a & R;
  endfunction
  assign y = f(x);
endmodule
