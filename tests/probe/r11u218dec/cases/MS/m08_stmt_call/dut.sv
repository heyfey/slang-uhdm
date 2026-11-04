// § opIdxRecvElemFollowsPath215 — (r11u218 independent grid of r11u215's laws) m08_stmt_call: the call as a statement (a task-like void method)
package p;
  class f_t;
    function void clr();
    endfunction
  endclass
  class r_t;
    f_t fields[$];
    function void g(int k);
      fields[k+1].clr();
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = 1;
endmodule
