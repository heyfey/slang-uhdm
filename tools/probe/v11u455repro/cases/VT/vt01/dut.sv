// § oobInheritedCallBindsOwnPkgClone455
// OOB task calling an imported free task inside fork and an imported function
package p;
  task t(int a); #1 $display(a); endtask
  function int f(int a); return a; endfunction
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern task g();
  endclass
  task C::g();
    fork
      t(f(v));
      t(2);
    join
  endtask
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); end
endmodule
