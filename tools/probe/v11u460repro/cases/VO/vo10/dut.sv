// § oobCopyCallBindsBodyHomeClone460 (static out-of-body function called through the class)
package p;
  function int f(int a); int cs; cs = a; return cs; endfunction
  task t(output int o); int cs; cs = 3; o = cs; endtask
endpackage
package q;
  import p::*;
  class C;
    extern static function int g(int x);
  endclass
  function int C::g(int x); return f(x); endfunction
endpackage
package s;
  import p::*;
  import q::*;
  class D;
    function int h(); return C::g(2); endfunction
  endclass
endpackage
module top;
  import s::*;
  D d;
  initial begin d = new; $display(d.h()); end
endmodule
