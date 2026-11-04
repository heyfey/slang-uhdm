// § cloneOwnCopyInstHomeTop482 (scalar struct local with an enum member)
package u;
  typedef enum {A, B} e_t;
  typedef struct { e_t e; int data; } op_t;
  function int f(int n);
    op_t s;
    s.e = B;
    s.data = n;
    return s.data;
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
