// § cloneBlockFixedArrTsParented244
package p;
  typedef int ia_t[4];
  class fac;
    function int emit(int n);
      int r;
      for (int i = 0; i < n; i++) begin
        logic [7:0] q[4];
        ia_t t;
        if (i > 0) begin
          bit b[2];
          b[0] = 1;
          r += b[0];
        end
        q[i%4] = i;
        t[0] = q[0];
        r += t[0];
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
