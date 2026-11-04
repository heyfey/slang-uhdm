// § cloneHierMemberChain482 (enum member then .name() call)
package u;
  typedef enum {A, B} e_t;
  typedef struct { e_t e; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    string s;
    acc[0].e = B;
    s = acc[0].e.name();
    return acc[1].z + n;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
