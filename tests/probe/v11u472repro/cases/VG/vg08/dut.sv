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
package q2;
  import p::*;
  class E #(int W = 1);
    extern task run();
  endclass
  task E::run(); endtask
endpackage
package r;
  import q::*;
  import q2::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule
