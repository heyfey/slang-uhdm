// § importCloneBodyLocalCopies175
package p1;
  function automatic int f(int n);
    int a[3];
    int x = n;
    return a[0] + x;
  endfunction
endpackage
package p2;
  import p1::f;
  localparam int K = 1;
endpackage
module top; int r; initial r = p1::f(1); endmodule
