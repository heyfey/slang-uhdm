// § refFullNameThroughNamedExpr175
package pa;
  localparam int W = 8;
  localparam int D = W / 2;
endpackage
package pb;
  import pa::*;
  function automatic int f(int a, int n = pa::W, int m = D);
    return a + n + m;
  endfunction
  class k;
    function int g(int x = pa::D + W);
      return x;
    endfunction
  endclass
endpackage
module top;
  import pb::*;
  k o; int r;
  initial begin o = new; r = f(1) + o.g(); end
endmodule
