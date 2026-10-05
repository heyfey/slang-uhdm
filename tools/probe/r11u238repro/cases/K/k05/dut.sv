// § cloneLoopVarClassPropArrayTs238
package p;
  class ov; string nm; endclass
  class fac;
    ov m_w[$];
    function int in_body(string s);
      int n;
      foreach (m_w[i]) if (m_w[i].nm == s) n++;
      foreach (this.m_w[j]) n++;
      return n;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class sub extends fac;
    function int more();
      int n;
      foreach (m_w[k]) n++;
      return n;
    endfunction
  endclass
endpackage
module top;
  import q::*;
  int x;
  initial begin
    sub s = new;
    x = s.more();
  end
endmodule
