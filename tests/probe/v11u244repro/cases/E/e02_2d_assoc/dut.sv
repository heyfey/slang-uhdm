// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    function int emit();
      int r;
      begin
        int q[2][3];
        int a[string];
        int d[];
        q[1][2] = 1;
        a["x"] = 2;
        d = new[3];
        foreach (a[k]) r += a[k];
        r += q[1][2] + d.size();
      end
      return r;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
