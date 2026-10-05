// § foreachFlatLocalRefTs238
package p;
  string names[$];
  int vals[3];
  class c;
    extern function void m_set;
  endclass
  function void c::m_set;
    string names[$];
    int vals[3];
    int other[2];
    int n;
    foreach (names[i]) n++;
    foreach (vals[j]) n += vals[j];
    foreach (other[k]) n += other[k];
  endfunction
endpackage
module top;
  import p::*;
  initial begin
    c o;
    o = new();
    o.m_set();
  end
endmodule
