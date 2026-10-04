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
// the header default read (no override), a body localparam argument
module sub #(parameter int unsigned N = 7) (output int o, output int p);
  localparam int unsigned LP = 9;
  assign o = q::w(N);
  assign p = q::w(LP);
endmodule
module top(output int o, output int p);
  sub u (.o(o), .p(p));
endmodule
