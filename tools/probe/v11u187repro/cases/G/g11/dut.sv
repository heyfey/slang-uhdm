// § cloneLoopVarHomeObject183 (dynamic array formal)
package u;
  function automatic int cnt(int a[]);
    int n;
    foreach (a[i]) n = n + a[i];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  function automatic int g(int a[]); return cnt(a); endfunction
endpackage
module top; endmodule
