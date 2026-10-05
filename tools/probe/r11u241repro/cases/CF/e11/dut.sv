// § cloneAggTsAtHomeListing241
package p;
  typedef union packed { logic [3:0] w; logic [3:0] v; } u_t;
  function automatic int f1(u_t b);
    u_t lu;
    lu = b;
    return int'(lu.w);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int x;
  initial x = f1(4'd2);
endmodule
