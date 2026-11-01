// § oobCopyCallBindsBodyHomeClone460 (module importer of p and q, no s)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
    extern task k();
  endclass
  function int C::g(); return f(v); endfunction
  task C::k(); t(v); endtask
endpackage
module top;
  import p::*;
  import q::*;
  C c;
  initial begin c = new; c.k(); $display(c.g()); end
endmodule
