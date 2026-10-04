// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned cnt2(logic [3:0] cfg);
    return cfg[0] + cfg[1];
  endfunction
  function automatic int sg(logic signed [3:0] x);
    return x;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (output int o, output int p);
  assign o = q::cnt(M);
  assign p = q::cnt2(M);
endmodule
module top(output int o, output int p);
  sub #(.M(3'b101)) u (.o(o), .p(p));
endmodule
