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
// instances in a for-generate and an if-generate
module sub #(parameter int unsigned N = 1) (output int o);
  assign o = q::w(N);
endmodule
module top(output int o[3]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.N(i+1)) u (.o(o[i]));
  end
  if (1) begin : h
    sub #(.N(7)) u (.o(o[2]));
  end
endmodule
