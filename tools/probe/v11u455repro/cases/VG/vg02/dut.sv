// § oobCloneViewKeepsPristine455v
// the param_vif shape: parameterized class in q, s imports only q and typedefs a specialization
package p;
  function int f(int a); $display(a); return a; endfunction
endpackage
package q;
  import p::*;
  class C #(int N = 1);
    int v;
    extern function int g();
  endclass
  function int C::g(); return f(v + N); endfunction
endpackage
package s;
  import q::*;
  typedef C #(4) C4;
endpackage
module top;
  import s::*;
  C4 c;
  initial begin c = new; $display(c.g()); end
endmodule
