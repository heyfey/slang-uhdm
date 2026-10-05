// § cloneLocalArrayTsParented241
package p;
  class qc; int v; endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    qc m[qc];
    qc w[*];
    begin
      qc nq[$];
      nq.delete();
    end
    foreach (m[k]) m[k] = null;
  endfunction
endpackage
package q;
  import p::*;
  class u; fac x; endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
