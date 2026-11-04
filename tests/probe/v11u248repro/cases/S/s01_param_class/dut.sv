// § cloneLoopVarClassPropStringTs248
package p;
  class c #(int N = 1);
    string m_name;
    extern function int unsigned depth();
  endclass
  function int unsigned c::depth();
    depth = N;
    foreach (m_name[i])
      if (m_name[i] == ".") depth++;
  endfunction
  class k;
    c #(3) h;
  endclass
endpackage
package q;
  import p::*;
  class u;
    function void g();
      k x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  initial w = new();
endmodule
