// § cloneLoopVarHomeObject183
package u;
  typedef struct { int f[4]; } st_t;
  function automatic int ss(st_t s);
    int n;
    foreach (s.f[i]) n = n + s.f[i];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
