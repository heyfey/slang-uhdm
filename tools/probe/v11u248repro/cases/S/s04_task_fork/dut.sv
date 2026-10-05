// § cloneLoopVarClassPropStringTs248
package p;
  class c;
    string m_name;
    extern task t(output int n);
  endclass
  task c::t(output int n);
    n = 0;
    fork
      begin
        foreach (m_name[i]) n += m_name[i];
      end
    join
  endtask
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
