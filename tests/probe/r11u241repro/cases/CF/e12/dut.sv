// § cloneAggTsAtHomeListing241
package p;
  typedef enum logic [1:0] { K_A, K_B } k_t;
  function automatic int f1(k_t a);
    k_t loc;
    loc = a;
    return int'(loc);
  endfunction
  task automatic t2(input k_t c, output int d);
    d = int'(c);
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int x;
  initial x = f1(K_A);
endmodule
