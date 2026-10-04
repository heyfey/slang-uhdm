// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (output int o);
  assign o = q::cnt(M);
endmodule
module top(output int o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
