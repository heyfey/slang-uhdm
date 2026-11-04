// § cloneAggTsAtHomeListing241
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic logic [3:0] f1(s_t x);
    return x.a ^ x.b;
  endfunction
endpackage
package q;
  import p::*;
  export p::*;
  function automatic logic [3:0] g(s_t x);
    return f1(x);
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import q::*;
  assign o = g(i);
endmodule
