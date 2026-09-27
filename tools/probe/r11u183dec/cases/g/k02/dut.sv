package u;
  function automatic bit has_wc(string arg);
    foreach (arg[i]) if (arg[i] == "*") return 1;
    return 0;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
