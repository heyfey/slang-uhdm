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
// override chain: the child value is the parent's parameter, the parent also calls
module sub #(parameter int unsigned N = 1) (output int o);
  assign o = q::w(N);
endmodule
module mid #(parameter int unsigned K = 0) (output int o, output int p);
  assign p = q::w2(K, 0);
  sub #(.N(K)) s (.o(o));
endmodule
module top(output int o, output int p);
  mid #(.K(3)) u (.o(o), .p(p));
endmodule
