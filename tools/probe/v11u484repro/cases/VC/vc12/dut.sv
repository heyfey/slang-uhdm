// § cloneAliasCopyBareName484 (home alias of an unpacked-array typedef, cloned (copy kind array))
package u;
  typedef struct { int k; } op_t;
  typedef op_t arr_t [2];
  typedef arr_t a2_t;
  function int f(int n);
    a2_t acc;
    acc[0].k = n;
    return acc[1].k;
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
