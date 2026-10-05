// § cloneLocalArrayTsParented241
package p;
  class qc; int v; endclass
  typedef qc qc_q[$];
  class fac;
    static function int n();
      qc_q t;
      qc s[$:3];
      return t.size() + s.size();
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; function int g(); return fac::n(); endfunction endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
