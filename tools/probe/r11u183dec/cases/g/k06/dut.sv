package u;
  class f;
    extern function int reg1(string a);
  endclass
  function int f::reg1(string a);
    int n;
    foreach (a[i]) n = n + 1;
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
