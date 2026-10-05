// § foreachClassPropStringTsShared238
// the string-property foreach inside an import clone of a class method, and in a class specialization
package p;
  class c #(int N = 1);
    string m_name;
    extern function int depth();
  endclass
  function int c::depth();
    int d = N;
    foreach (m_name[i]) if (m_name[i] == ".") d++;
    return d;
  endfunction
  typedef c #(2) c2_t;
endpackage
package q;
  import p::*;
  function int g();
    c2_t x = new;
    c #(3) y = new;
    return x.depth() + y.depth();
  endfunction
endpackage
module top;
  int r;
  initial r = q::g();
endmodule
