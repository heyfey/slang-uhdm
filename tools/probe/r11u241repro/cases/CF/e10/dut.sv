// § cloneAggTsAtHomeListing241
package p;
  typedef enum logic [1:0] { K_A, K_B } k_t;
  typedef union packed { logic [3:0] w; logic [3:0] v; } u_t;
  function automatic int f1(k_t a, u_t b);
    k_t loc;
    u_t lu;
    loc = a;
    lu = b;
    return int'(loc) + int'(lu.w);
  endfunction
  task automatic t2(input k_t c, output u_t d);
    d = '0;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int x;
  initial x = f1(K_A, 4'd2);
endmodule
