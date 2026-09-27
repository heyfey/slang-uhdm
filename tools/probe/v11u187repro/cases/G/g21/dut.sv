// § cloneLoopVarHomeObject183 (ref and const ref formals)
package u;
  function automatic int tot(ref int a[$], const ref int b[]);
    int n;
    foreach (a[i]) n = n + a[i];
    foreach (b[j]) n = n + b[j];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
