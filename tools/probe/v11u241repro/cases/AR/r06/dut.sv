// § cloneLocalArrayTsParented241
`define QDECL(T, N) T N[$];
package p;
  class qc; int v; endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    `QDECL(qc, sq)
    qc dd[][];
    sq.delete();
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
