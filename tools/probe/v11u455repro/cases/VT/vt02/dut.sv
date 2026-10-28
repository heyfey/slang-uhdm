// § oobInheritedCallBindsOwnPkgClone455
// OOB function calling an imported task inside fork join_none
package p;
  task t(int a); #1 $display(a); endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function void g();
  endclass
  function void C::g();
    fork
      t(v);
    join_none
  endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); #5; end
endmodule
