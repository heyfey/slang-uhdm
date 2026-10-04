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
// an enum parameter to an enum formal, and a string parameter to a string formal
module sub #(parameter q::e_t E = q::E1, parameter string S = "abc") (output int o, output int s);
  assign o = q::ef(E);
  assign s = q::sf(S);
endmodule
module top(output int o, output int s);
  sub #(.E(q::E2), .S("hello")) u (.o(o), .s(s));
endmodule
