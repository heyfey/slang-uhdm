// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h1F;
endpackage
module top(output int y, output int z);
  import p::*;
  function automatic int f(int a);
    return H;
  endfunction
  function automatic int g(int a);
    return a;
  endfunction
  assign y = f(1);
  assign z = g(H);
endmodule
