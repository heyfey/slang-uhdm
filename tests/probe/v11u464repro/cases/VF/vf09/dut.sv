// § unitImpTfNameDedup464 (the module calls the first import's f)
package p1;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package p2;
  function automatic int g(int x); return x + 2; endfunction
  function automatic int f2(int x); return x + 2; endfunction
endpackage
import p1::*;
import p2::*;
module top(input logic [1:0] i, output int o);
  assign o = f(i) + g(i);
endmodule
