// § cloneOwnCopyInstHomeTop482 (struct with a member typed by an enum of a third package)
package s;
  typedef enum {A, B} e_t;
endpackage
package u;
  import s::*;
  typedef struct { s::e_t e; int data; } op_t;
  function int f(int n);
    op_t s0;
    s0.data = n;
    return s0.data;
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
