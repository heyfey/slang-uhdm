// § cloneForIncBindsHomeVar238
// one home function cloned into two importing packages and a re-exporting chain
package p;
  function int h(int n);
    int c;
    c = 0;
    for (int b = 0; b < n; b++) c += b;
    return c;
  endfunction
endpackage
package q;
  import p::*;
  export p::*;
  function int qh(int n); return h(n); endfunction
endpackage
package r;
  import p::*;
  function int rh(int n); return h(n) + 1; endfunction
endpackage
package z;
  import q::*;
  function int zh(int n); return qh(n) + h(n); endfunction
endpackage
module top;
  int r1, r2, r3;
  initial begin
    r1 = q::qh(2);
    r2 = r::rh(2);
    r3 = z::zh(2);
  end
endmodule
