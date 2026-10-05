// § foreachFlatLocalRefTs238
package p;
  class c;
    extern function void m_set;
  endclass
  function void c::m_set;
    static string values[$];
    foreach (values[i]) values[i] = "z";
  endfunction
endpackage
import p::*;
module top;
  c o;
  initial begin o = new; o.m_set(); end
endmodule
