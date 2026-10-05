// § blkElemCopyDeclDimsOnly244v
package p;
  typedef int ia_t[4];
  typedef int iq_t[$];
  typedef int id_t[];
  typedef ia_t ia2_t[2];
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r;
    begin
      ia_t a;
      iq_t q;
      id_t d;
      ia_t b[3];
      ia2_t c;
      a[0] = 1; q.push_back(2); d = new[1]; b[0][1] = 3; c[1][2] = 4;
      r = a[0] + q[0] + d.size() + b[0][1] + c[1][2];
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
