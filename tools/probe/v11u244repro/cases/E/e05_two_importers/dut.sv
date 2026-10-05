// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    function int emit();
      int r;
      begin int q[5]; q[0] = 1; r = q[0]; end
      return r;
    endfunction
  endclass
endpackage
package q1; import p::*; class u1; function void f(); fac x; x = null; endfunction endclass endpackage
package q2; import p::*; class u2; function void f(); fac x; x = null; endfunction endclass endpackage
module top; import p::*; import q1::*; import q2::*; fac z; u1 a; u2 b; initial begin a = new(); b = new(); end endmodule
