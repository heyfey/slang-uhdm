// § grpOwnOobGenericCls472
package q;
  class D #(int W = 1);
    extern task run();
  endclass
  task D::run(); endtask
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule
