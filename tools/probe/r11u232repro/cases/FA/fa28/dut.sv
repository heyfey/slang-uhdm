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
module sub #(parameter q::mask_t M = '0) (input int a, output int o);
  assign o = a + q::cnt(M);
endmodule
module top(input int a, output int o);
  sub #(.M(3'b101)) u (.a(a), .o(o));
endmodule
