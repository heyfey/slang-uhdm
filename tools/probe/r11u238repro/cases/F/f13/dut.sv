// § foreachClassPropStringTsShared238
package p;
  class c #(type T = int);
    string m_name;
    T m_t;
    extern function int depth();
  endclass
  function int c::depth();
    foreach (m_name[i]) depth++;
    foreach (this.m_name[j]) depth++;
  endfunction
  typedef c#(byte) cb_t;
endpackage
module top;
  p::c #(bit) a;
  p::cb_t b;
  int r;
  initial begin
    a = new; b = new;
    r = a.depth() + b.depth();
  end
endmodule
