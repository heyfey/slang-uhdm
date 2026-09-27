// § importCloneBodyLocalCopies175
package p1;
  function automatic int f(int n);
    int a = n + 1;
    logic [7:0] b = 8'hA5;
    return a + b;
  endfunction
endpackage
package p2;
  import p1::*;
  localparam int K = 2;
endpackage
module top; import p2::*; int r; initial r = p1::f(K); endmodule
