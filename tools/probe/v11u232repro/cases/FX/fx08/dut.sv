// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w(int unsigned x);
    return x + 1;
  endfunction
  function automatic int unsigned w2(logic [7:0] x, int unsigned y);
    return x + y;
  endfunction
endpackage
// a net argument beside the parameter argument (first position is the parameter)
module sub #(parameter int unsigned N = 1) (input int a, output int o);
  assign o = q::w2(N, a);
endmodule
module top(input int a, output int o);
  sub #(.N(5)) u (.a(a), .o(o));
endmodule
