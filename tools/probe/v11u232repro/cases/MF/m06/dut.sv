// § caCallArgParamFormalTs232
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
// a struct parameter to a struct formal; type-operator cast
module sub #(parameter q::pr_t P = '0, parameter logic [7:0] N = 0) (output int o, output int t);
  assign o = q::pf(P);
  assign t = q::w8(N + 8'd0);
endmodule
module top(output int o, output int t);
  sub #(.P(8'h5A), .N(8'd9)) u (.o(o), .t(t));
endmodule
