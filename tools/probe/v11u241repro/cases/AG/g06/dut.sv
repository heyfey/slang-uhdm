// § cloneAggTsAtHomeListing241
package p;
  typedef enum logic [1:0] { K_A, K_B } k_t;
  function automatic int f1(input k_t a);
    k_t loc = a;
    return int'(loc);
  endfunction
endpackage
package p2;
  typedef enum logic [1:0] { K_C, K_D } k_t;
  function automatic int f1b(input k_t a);
    return int'(a);
  endfunction
endpackage
package q;
  import p::*;
  import p2::f1b;
endpackage
module top;
  import p::*;
  int x;
  initial x = f1(K_A) + p2::f1b(p2::K_C);
endmodule
