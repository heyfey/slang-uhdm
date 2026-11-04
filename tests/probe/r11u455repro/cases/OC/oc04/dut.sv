// § oobInheritedCallBindsOwnPkgClone455
package p;
  task t(int a); $display(a); endtask
  class B;
    task t(int a); $display(a + 1); endtask
  endclass
endpackage
package q;
  import p::*;
  class C extends B;
    extern task g();
  endclass
  task C::g(); t(2); endtask
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); end
endmodule
