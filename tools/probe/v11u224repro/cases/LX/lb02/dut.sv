// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  function automatic s_t f(s_t s, logic [1:0] i, logic [1:0] d);
    s.arr[i][1:0] = d;
    return s;
  endfunction
endpackage
package q;
  import p::*;
  function automatic s_t g(s_t s); return f(s, 1, 2); endfunction
endpackage
module top(output logic [32:0] o); import q::*; assign o = g('0); endmodule
