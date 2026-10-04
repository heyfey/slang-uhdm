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
// an implicit net on the left, a named argument; a second instance at depth 3
module sub #(parameter q::mask_t M = '0) (output int o);
  assign impl = q::cnt(.cfg(M)) > 1;
  assign o = impl;
endmodule
module mid #(parameter q::mask_t M = '0) (output int o);
  sub #(.M(M)) s (.o(o));
endmodule
module top(output int o, output int p);
  mid #(.M(3'b011)) u (.o(o));
  sub #(.M(3'b111)) v (.o(p));
endmodule
