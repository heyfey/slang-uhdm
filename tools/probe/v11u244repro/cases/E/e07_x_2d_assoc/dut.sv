// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r;
    begin
      int q[2][3];
      int a[string];
      int d[];
      int qq[$];
      q[1][2] = 1;
      a["x"] = 2;
      d = new[3];
      qq.push_back(1);
      foreach (a[k]) r += a[k];
      foreach (q[i, j]) r += q[i][j];
      r += q[1][2] + d.size() + qq[0];
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
