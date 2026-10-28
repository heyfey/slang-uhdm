// § oobInheritedCallBindsOwnPkgClone455
// imported function in a local declaration initializer and a named block of an OOB method
package p;
  function int f(int a); return a + 1; endfunction
  task t(output int o); o = 5; endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern task g();
  endclass
  task C::g();
    int loc = f(v);
    begin : nb
      int k;
      t(k);
      v = loc + k + f(k);
    end
  endtask
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); end
endmodule
