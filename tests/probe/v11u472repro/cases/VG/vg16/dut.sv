// § grpOwnOobGenericCls472
`define OOB(N) function void D::N(); endfunction
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern function void zz();
    extern function void aa();
  endclass
  `OOB(zz)
  `OOB(aa)
endpackage
module top;
  import q::*;
  class S;
    D #(2) h;
  endclass
endmodule
