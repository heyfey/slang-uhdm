// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r;
    r = 0;
    for (int i = 0; i < 2; i++) begin
      int q[3];
      q[i] = i;
      r += q[i];
    end
    if (r > 0) begin : nb
      int w[$];
      w.push_back(r);
      r = w[0];
    end
    begin
      begin
        int fq[2];
        fq[0] = 1;
      end
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
