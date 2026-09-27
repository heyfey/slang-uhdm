// § cloneLoopVarHomeObject183 (typedef array formal)
package u;
  typedef int arr_t[3];
  function automatic int tot(arr_t a);
    int n;
    foreach (a[i]) n = n + a[i];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
