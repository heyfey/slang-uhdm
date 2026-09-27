// § cloneLoopVarHomeObject183 (a subroutine-local array)
package u;
  function automatic int loc();
    int a[4];
    int n;
    foreach (a[i]) n = n + i;
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
