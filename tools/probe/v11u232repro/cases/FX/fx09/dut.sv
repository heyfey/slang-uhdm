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
// the parameter also a bare range bound and a localparam initializer (shared constants)
module sub #(parameter int unsigned N = 1) (output int o, output logic [N:0] r);
  localparam int unsigned L = N;
  assign o = q::w(N);
  assign r = '0;
endmodule
module top(output int o, output logic [5:0] r);
  sub #(.N(5)) u (.o(o), .r(r));
endmodule
