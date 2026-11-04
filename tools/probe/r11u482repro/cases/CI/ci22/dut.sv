// § cloneOwnCopyInstHomeTop482 (scalar enum local)
package u;
  typedef enum { E0, E1 } e_t;
  function int f(int n);
    e_t e;
    e = E1;
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
