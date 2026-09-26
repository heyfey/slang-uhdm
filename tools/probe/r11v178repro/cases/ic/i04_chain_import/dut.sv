// § importCloneBodyLocalCopies175
package p1;
  typedef int iv_t [2];
  function automatic int f(int n);
    iv_t a;
    static int s = 5;
    int x = n + s;
    a[0] = x;
    return a[0];
  endfunction
endpackage
package p2;
  import p1::*;
  export p1::*;
endpackage
package p3;
  import p2::*;
endpackage
module top; int r; initial r = p1::f(1); endmodule
