// § caCallArgTruncByBase232v
package q;
  typedef logic [0:2] mask_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pr_t;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w8(logic [7:0] x);
    return x + 1;
  endfunction
  function automatic int unsigned w4(logic [3:0] x);
    return x + 2;
  endfunction
  function automatic int unsigned ef(e_t x);
    return x;
  endfunction
  function automatic int unsigned sf(string s);
    return s.len();
  endfunction
  function automatic int unsigned pf(pr_t x);
    return x.a + x.b;
  endfunction
endpackage
// a package-qualified function called through an import, from a class-specialization bound context and a header parameter used as a port range
import q::*;
module sub #(parameter logic [7:0] N = 8'hF0) (output logic [w4(N)-1:0] o, output int p);
  assign p = w8(N) + w4(N);
  assign o = '0;
endmodule
module top(output logic [17:0] o, output int p);
  sub #(.N(8'hAB)) u (.o(o), .p(p));
endmodule
