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
module sub #(parameter q::mask_t M = '0, parameter int K = 2) (output logic [7:0] o);
  assign o[K] = q::cnt(M) > 0;
endmodule
module top(output logic [7:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
