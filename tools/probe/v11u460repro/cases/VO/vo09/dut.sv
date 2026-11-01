// § oobCopyCallBindsBodyHomeClone460 (two importer packages)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  class C;
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v); endfunction
endpackage
package s1;
  import p::*;
  import q::*;
  class D1 extends C; endclass
endpackage
package s2;
  import p::*;
  import q::*;
  class D2 extends C; endclass
endpackage
module top;
  import s1::*;
  import s2::*;
  D1 a; D2 b;
  initial begin a = new; b = new; $display(a.g() + b.g()); end
endmodule
