// § cloneLoopVarClassPropStringTs248
// the loop variable in constant slots of the body: part-select bounds, indexed widths, replication
package p;
  class c;
    string m_name;
    bit [15:0] m_w;
    extern function void f();
  endclass
  function void c::f();
    foreach (m_name[i]) begin
      m_w[i +: 2] = {2{1'b1}};
      m_w[3:0] = m_name[i];
      m_w[i -: 1] = m_w[i];
    end
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c x;
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
