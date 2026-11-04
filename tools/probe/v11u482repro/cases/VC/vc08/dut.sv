// § cloneOwnCopyInstHomeTop482 (enum local of the home package)
package u;
  typedef enum {A, B, C} e_t;
  function int f(int n);
    e_t e;
    e = B;
    return int'(e) + n;
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
