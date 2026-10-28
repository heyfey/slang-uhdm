// § hpVsParenBoundPretty453
package p;
  typedef struct packed { logic [3:0][7:0] pg; } t_s;
  function automatic logic [1:0] f(t_s s, int i0);
    return s.pg[i0][(i0)+:2];
  endfunction
endpackage
module top;
  import p::*;
endmodule
