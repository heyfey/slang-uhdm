// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern task run();
  endclass
  task D::run(); endtask
endpackage
package r;
  import p::*;
  import q::*;
  class S;
    int k;
  endclass
  class R2 #(int X = 0);
    extern function void rr();
  endclass
  function void R2::rr(); endfunction
endpackage
package t;
  import p::*;
  import q::*;
  import r::*;
  class U;
    int k;
  endclass
  class V;
    int j;
  endclass
endpackage
module top;
  import t::*;
endmodule
