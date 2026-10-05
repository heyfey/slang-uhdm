// § foreachClassPropStringTsShared238
package p;
  class c;
    string m_name;
    static string s_name;
    extern function int depth(string m_name);
    extern function int sdepth();
  endclass
  function int c::depth(string m_name);
    foreach (m_name[i]) depth++;
  endfunction
  function int c::sdepth();
    c o = new;
    foreach (s_name[i]) sdepth++;
    foreach (o.m_name[k]) sdepth++;
  endfunction
endpackage
import p::*;
module top;
  c o;
  initial begin o = new; void'(o.sdepth()); end
endmodule
