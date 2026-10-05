// § cloneAggTsAtHomeListing241
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic logic [3:0] f1(s_t x);
    s_t y;
    y = x;
    return y.a ^ y.b;
  endfunction
  function automatic logic [3:0] f2(s_t z);
    return z.b;
  endfunction
endpackage
package q;
  import p::f1;
  import p::f2;
  import p::s_t;
  export p::f1;
  export p::f2;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import q::*;
  assign o = f1(i) | f2(i);
endmodule
