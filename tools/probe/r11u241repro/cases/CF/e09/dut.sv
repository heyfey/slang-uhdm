// § cloneAggTsAtHomeListing241
package r;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  typedef enum logic [1:0] { R_A, R_B } e_t;
  function automatic int rf(s_t v, e_t w);
    return int'(v.a) + int'(w);
  endfunction
endpackage
package p;
  import r::*;
  function automatic int f1(s_t x, e_t y);
    s_t loc;
    e_t le;
    loc = x;
    le = y;
    return int'(loc.b) + int'(le);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int z;
  initial z = f1(5'd3, r::R_B);
endmodule
