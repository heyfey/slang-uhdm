// § cloneLoopVarHomeObject183
package u;
  function automatic bit has_wc(string arg);
    foreach (arg[i]) if (arg[i] == "*") return 1;
    return 0;
  endfunction
endpackage
package s;
  import u::*;
  function automatic bit g(string a); return has_wc(a); endfunction
endpackage
module top;
  import s::*;
  initial $display(g("a*"));
endmodule
