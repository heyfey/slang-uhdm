// § cloneHpIdxNamesByChain220 § cloneIdxOwnCopyOnly220 — an out-of-body class method with path-select indices, imported by two packages and read from a module
package p1;
  typedef struct { int a; int v [4]; } s_t;
  class c;
    s_t arr [4];
    extern function int f(int i, int k);
  endclass
  function int c::f(int i, int k);
    return arr[i].v[k] + arr[k].a;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
